Arena-Client
============

An iOS Client for Arena's API  

[are.na](https://are.na/)

API Documentation

[dev.are.na](http://dev.are.na/)

Getting Started
----

```objective-c
#import "Arena.h"
...

[Arena SetToken:@"xxxxxxxxxxxxxxxx"];
NSDictionary *channel=[Arena CreateChannel:@"My Channel"];
```

Todo
----

1. Image upload
2. Searching
3. Alerts for missing access token
