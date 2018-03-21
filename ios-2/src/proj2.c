#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <semaphore.h>
#include <fcntl.h>
#include <time.h>

// Structure for handling semaphores
struct Semaphores
{
  sem_t * load;
  sem_t * unload;
  sem_t * run;
  sem_t * write;
  sem_t * finish;
};

// Structure for handling shared memory
struct Memory
{
  int boarded;
  int actionNumber;
  int totalPassengers;
  int carCap;
  int genSleep;
  int carSleep;
  int pgpid;
  FILE * out;
};

// Function handling the arguments, ensuring only the correct values are let through.
int checkParams(int * argCount, char * argValue[])
{
  char * buff;

  // Every argument inside the brackets is written in its positive form...
  if (*argCount != 4) {
    fprintf(stderr, "Number of arguments doesn't match. Required number of arguments is 4.\n");
    return 1;
  }
  else if (strtol(argValue[1], &buff, 0) <= 0) {
    fprintf(stderr, "First argument (number of passengers) is not greater than zero.\n");
    return 1;
  }
  else if (strtol(argValue[2], &buff, 0) <= 0) {
    fprintf(stderr, "Second argument (car capacity) is not greater than zero.\n");
    return 1;
  }
  else if (strtol(argValue[1], &buff, 0) <= strtol(argValue[2], &buff, 0)) {
    fprintf(stderr, "First argument (number of passengers) is not greater than the second argument (car capacity).\n");
    return 1;
  }
  else if (strtol(argValue[1], &buff, 0) % strtol(argValue[2], &buff, 0) != 0)
  {
    fprintf(stderr, "First argument (number of passengers) is not multiple of the second argument (car capacity).\n");
    return 1;
  }
  else if (strtol(argValue[3], &buff, 0) <= 0 || strtol(argValue[3], &buff, 0) > 5000)
  {
    fprintf(stderr, "Third argument (maximal time to wait before generation of a new passenger process) is out of limits (0 =< x < 5001).\n");
    return 1;
  }
  else if (strtol(argValue[4], &buff, 0) <= 0 || strtol(argValue[4], &buff, 0) > 5000)
  {
    fprintf(stderr, "Fourth argument (maximal duration of a car ride) is out of limits (0 =< duration < 5001).\n");
    return 1;
  }
  return 0;
}

// Closes output file, all semaphores and releases all used shared memory
void releaseResources(struct Semaphores * sem, struct Memory * mem, int * shmid)
{
  fclose(mem->out);

  sem_close(sem->load);
  sem_close(sem->unload);
  sem_close(sem->run);
  sem_close(sem->write);
  sem_close(sem->finish);

  munmap(mem, sizeof(struct Memory));

  sem_unlink("/xcagas01-semload");
  sem_unlink("/xcagas01-semunload");
  sem_unlink("/xcagas01-semRun");
  sem_unlink("/xcagas01-semWrite");
  sem_unlink("/xcagas01-semFinish");

  shm_unlink("/xcagas01-shm");

  close(*shmid);

  return;
}

void car(struct Semaphores * sem, struct Memory * mem, int carID)
{
  int iter = mem->totalPassengers/mem->carCap;

  sem_wait(sem->write);
  mem->actionNumber += 1;
  fprintf(mem->out, "%-8d: C %-4d: started\n", mem->actionNumber, carID);
  sem_post(sem->write);

  for (int i = 0; i < iter; i++)
  {
    sem_wait(sem->write);
    mem->actionNumber += 1;
    fprintf(mem->out, "%-8d: C %-4d: load\n", mem->actionNumber, carID);
    sem_post(sem->write);
    sem_post(sem->load);

    sem_wait(sem->run);
    sem_wait(sem->write);
    mem->actionNumber += 1;
    fprintf(mem->out, "%-8d: C %-4d: run\n", mem->actionNumber, carID);
    sem_post(sem->write);

    if (mem->genSleep != 0)
    {
      srand(time(NULL) * getpid());
      usleep((rand()%(mem->carSleep)*1000));
    }

    sem_wait(sem->write);
    mem->actionNumber += 1;
    fprintf(mem->out, "%-8d: C %-4d: unload\n", mem->actionNumber, carID);
    sem_post(sem->write);
    sem_post(sem->unload);
  }

  sem_wait(sem->load);
  sem_wait(sem->write);
  mem->actionNumber += 1;
  fprintf(mem->out, "%-8d: C %-4d: finished\n", mem->actionNumber, carID);
  sem_post(sem->write);
  sem_post(sem->finish);

  return;
}

void passenger(struct Semaphores * sem, struct Memory * mem, int passengerID)
{
  sem_wait(sem->write);
  mem->actionNumber += 1;
  fprintf(mem->out, "%-8d: P %-4d: started\n", mem->actionNumber, passengerID);
  sem_post(sem->write);

  sem_wait(sem->load);
  sem_wait(sem->write);
  mem->boarded += 1;
  mem->actionNumber += 1;
  fprintf(mem->out, "%-8d: P %-4d: board\n", mem->actionNumber, passengerID);
  sem_post(sem->write);
  if (mem->boarded == mem->carCap)
  {
    sem_wait(sem->write);
    mem->actionNumber += 1;
    fprintf(mem->out, "%-8d: P %-4d: board order last\n", mem->actionNumber, passengerID);
    sem_post(sem->write);
    sem_post(sem->run);
  }
  else
  {
    sem_wait(sem->write);
    mem->actionNumber += 1;
    fprintf(mem->out, "%-8d: P %-4d: board order %d\n", mem->actionNumber, passengerID, mem->boarded);
    sem_post(sem->write);
    sem_post(sem->load);
  }

  sem_wait(sem->unload);
  sem_wait(sem->write);
  mem->actionNumber += 1;
  fprintf(mem->out, "%-8d: P %-4d: unboard\n", mem->actionNumber, passengerID);
  mem->boarded -= 1;
  if (mem->boarded == 0)
  {
    mem->actionNumber += 1;
    fprintf(mem->out, "%-8d: P %-4d: unboard last\n", mem->actionNumber, passengerID);
    sem_post(sem->write);
    sem_post(sem->load);
  }
  else
  {
    mem->actionNumber += 1;
    fprintf(mem->out, "%-8d: P %-4d: unboard order %d\n", mem->actionNumber, passengerID, mem->carCap-mem->boarded);
    sem_post(sem->write);
    sem_post(sem->unload);
  }

  sem_wait(sem->finish);
  sem_wait(sem->write);
  mem->actionNumber += 1;
  fprintf(mem->out, "%-8d: P %-4d: finished\n", mem->actionNumber, passengerID);
  sem_post(sem->write);
  sem_post(sem->finish);

  return;
}

void sigtermHandler()
{
  kill(0, SIGUSR1);
  exit(2);
}

int main (int argc, char * argv[])
{
  signal(SIGUSR1, SIG_IGN);

  setbuf(stderr, NULL);

  // Tests the validity of parameters, for details please refer to checkParams() routine
  if(checkParams(&argc, argv) == 1)
  {
    return 1;
  }

  struct Semaphores sem;
  struct Memory * mem;

  int pid;

  int carID = 0;
  int passengerID = 0;

  // Shared memory
  int shmid = shm_open("/xcagas01-shm", O_CREAT | O_EXCL | O_RDWR, 0644);
  ftruncate(shmid, sizeof(struct Memory));
  mem = (struct Memory *) mmap(NULL, sizeof(struct Memory), PROT_READ | PROT_WRITE, MAP_SHARED, shmid, 0);
  if (mem == NULL)
  {
    fprintf(stderr, "Unable to create shared memory.\n");
    return 2;
  }

  // Attempts to create the output file
  // If file with the name proj2.out is present, it will be rewritten
  mem->out = fopen("./proj2.out",  "w");
  if (mem->out == NULL)
  {
    fprintf(stderr, "Failed to create/rewrite output file.\n");
    munmap(mem, sizeof(struct Memory));
    shm_unlink("/xcagas01-shm");
    close(shmid);
    exit(2);
  }

  // Creation and initialisation of semaphores
  sem.load = sem_open("/xcagas01-semload", O_CREAT | O_EXCL, 0644, 0);
  sem.unload = sem_open("/xcagas01-semunload", O_CREAT | O_EXCL, 0644, 0);
  sem.run = sem_open("/xcagas01-semRun", O_CREAT | O_EXCL, 0644, 0);
  sem.write = sem_open("/xcagas01-semWrite", O_CREAT | O_EXCL, 0644, 0);
  sem.finish = sem_open("/xcagas01-semFinish", O_CREAT | O_EXCL, 0644, 0);

  // Initialisation of shared memory variables
  char * buff;

  mem->boarded = 0;
  mem->actionNumber = 0;
  mem->totalPassengers = strtol(argv[1], &buff, 0);
  mem->carCap = strtol(argv[2], &buff, 0);
  mem->genSleep = strtol(argv[3], &buff, 0);
  mem->carSleep = strtol(argv[4], &buff, 0);

  mem->pgpid = getpgid(0);

  setbuf(mem->out, NULL);

  if ((pid = fork()) < 0)
  {
    sem_wait(sem.write);
    fprintf(stderr, "Failed to create the car process.\n");
    sem_post(sem.write);
    killpg(mem->pgpid, SIGUSR1);
    sigtermHandler();
  }
  if (pid == 0)
  {
    // process car
    setpgrp();
    carID += 1;
    car(&sem, mem, carID);
    exit(0);
  }

  if ((pid = fork()) < 0)
  {
    sem_wait(sem.write);
    fprintf(stderr, "Failed to create the auxiliary process.\n");
    sem_post(sem.write);
    killpg(mem->pgpid, SIGUSR1);
    sigtermHandler();
  }
  if (pid == 0)
  {
    //auxiliary process
    setpgrp();
    for (int i = 0; i < mem->totalPassengers; i++)
    {
      passengerID += 1;

      if ((pid = fork()) < 0)
      {
        sem_wait(sem.write);
        fprintf(stderr, "Failed to create a passenger process.\n");
        sem_post(sem.write);
        killpg(mem->pgpid, SIGUSR1);
        sigtermHandler();
      }
      if (pid == 0)
      {
        // passenger process
        setpgrp();
        passenger(&sem, mem, passengerID);
        exit(0);
      }
      if (mem->genSleep != 0)
      {
        srand(time(NULL) * getpid());
        usleep((rand()%(mem->genSleep)*1000));
      }
    }
    exit(0);
  }

  int status;
  for (int i = 0; i < mem->totalPassengers + 2; i++)
  {
    wait(&status);
    if (WEXITSTATUS(status) == 2)
    {
      killpg(mem->pgpid, SIGUSR1);
      releaseResources(&sem, mem, &shmid);
      sigtermHandler();

      return 2;
    }
  }
  releaseResources(&sem, mem, &shmid);
  return 0;
}
