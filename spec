TINYCI

Features:
 * Shows various task statuses in a matrix:
   - Three test stages: CONFIG, EXEC/BUILD, TEST
   - Possible states: RUNNING, OK, NOK, N/A
   - Shows logs for each steps
  
 * Manually can be executed:
   - Exec: run all steps
   - Clean: cleans build files ("make clean")
   - Purge: resets environment ("rm -rf build")

 * Bash script back-end
    - Run through cron
    - Standard interface for tasks
        + functions: config, build, test, clean, purge
    - Reports results to a defined folder/file structure
        + report-root
            d task-name
                d time-stamp
                    f config.status (the state of the phase if available)
                    f build.status (the state of the phase if available)
                    f test.status (the state of the phase if available)
                    f config.log (the log if available)
                    f build.log (the log if available)
                    f test.log (the log if available)
    - Scripts have the following variables set:
        + LOGFILE - where to output everything
    - Scripts have the following functions:
        + status(status_string) - outputs the current status
        + 

 * PHP web front-end
    - Config file telling the paths
    - Prints task run statuses in a matrix per task
    - Provides access to logs in the matrix
    - Provides access to outputs
    - Allows manual runs

