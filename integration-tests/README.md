Temporary readme

First start up Mountebank:

    guest$ mb &

Now send in the script:

    guest$ curl -X POST -d @/vagrant/integration-tests/imposter.json http://localhost:2525/imposters

Now update the URL for your emitter:

```objective-c
    NSURL *url = [NSURL URLWithString: @"http://localhost:4545"];
```

Now open Mountebank in your browser (on host is fine):

    [http://localhost:2525/imposters/4545](http://localhost:2525/imposters/4545)
