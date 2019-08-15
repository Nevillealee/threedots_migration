# threedots_migration

## Start the app

In a new terminal
```
rails s
```

Then in a second terminal tab
```
QUEUE=* COUNT=5 rake resque:workers
```
