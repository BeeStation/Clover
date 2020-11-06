// A shoddy implementation of something resembling await to use with async http calls.

#define AWAIT(x) while(!(x)) sleep(3 * world.tick_lag) //Check every 3 ticks. Why 3? *shrug*
