//
//  Arena.m
//  ArenaClient
//
//  Created by Robin Willis on 7/30/13.
//  Copyright (c) 2013 Robin Willis. All rights reserved.
//

#import "Arena.h"
#import "NSData+Additions.h"

@implementation Arena

static Arena *instance =nil;

+ (Arena *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance= [Arena new];
            instance.arenaAPI = @"v2/";
            instance.baseURL = [NSString stringWithFormat: @"http://api.are.na/%@", instance.arenaAPI];
     
        }
    }
    return instance;
}

+ (void) SetToken:(NSString *)token{
    Arena *arena=[Arena getInstance];
    arena.access_token = token;
}

+ (NSString *)serializeParams:(NSDictionary *)params {
    
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString* key in [params keyEnumerator]) {
        id value = [params objectForKey:key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            for (NSString *subKey in value) {
                NSString *escaped_value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                              (CFStringRef)[value objectForKey:subKey],
                                                                                              NULL,
                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                              kCFStringEncodingUTF8));
                [pairs addObject:[NSString stringWithFormat:@"%@[%@]=%@", key, subKey, escaped_value]];
            }
        } else if ([value isKindOfClass:[NSArray class]]) {
            for (NSString *subValue in value) {
                NSString* escaped_value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                              (CFStringRef)subValue,
                                                                                              NULL,
                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                              kCFStringEncodingUTF8));
                [pairs addObject:[NSString stringWithFormat:@"%@[]=%@", key, escaped_value]];
            }
        } else {
            NSString* escaped_value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                          (CFStringRef)[params objectForKey:key],
                                                                                          NULL,
                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                          kCFStringEncodingUTF8));
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
        }
    }
    return [pairs componentsJoinedByString:@"&"];
    
}

+ (NSDictionary *) GetRequest:(NSString *)URLString
{
    Arena  *arena=[Arena getInstance];
    NSString *url=[NSString stringWithFormat:@"%@%@",arena.baseURL, URLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:url]];
    
    if(arena.access_token != nil){
        NSString *authorization = [NSString stringWithFormat:@"Bearer %@",arena.access_token];
        [request setValue:authorization forHTTPHeaderField:@"Authorization"];
    }
    
    [request setHTTPMethod:@"GET"];
    
    NSLog(@"%@",request);
    @try
    {
        NSURLResponse *serverResponse;
        NSError *myError = nil;
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&serverResponse error:&myError];
        
        didReceiveResponse:serverResponse;
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)serverResponse;
            NSLog(@"%@", [httpResponse allHeaderFields]);
        }
        
        if (myError!=nil)
        {
            NSLog(myError.debugDescription);
            return nil;
        }
       
        
        if (returnData==nil) {
            return nil;
        }
        NSError *serialError = nil;
        NSMutableDictionary  *responseSerialized = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:&serialError];
        return responseSerialized;
        
    }
    @catch (NSException *ex)
    {
        @throw ex;
    }    
}

#pragma mark Base Http Requests

+ (NSDictionary *) PostRequest:(NSString *)URLString With:(NSDictionary *)parameters
{
    Arena  *arena=[Arena getInstance];
    
    NSString *url=[NSString stringWithFormat:@"%@%@",arena.baseURL, URLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:url]];
    
    NSError *error;

    NSString *post = [self serializeParams:parameters];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    NSString *authorization = [NSString stringWithFormat:@"Bearer %@",arena.access_token];
    
    [request setValue:authorization forHTTPHeaderField:@"Authorization"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    @try
    {
        NSURLResponse *serverResponse;
        NSError *myError = nil;
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&serverResponse error:&myError];
        
        if (myError!=nil)
        {
            return nil;
        }
        
        if (returnData==nil) {
            return nil;
        }
        
        NSError *serializeError = nil;
        
        NSMutableDictionary  *serializedResponse = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:&serializeError];
        
        return serializedResponse;
        
    }
    @catch (NSException *ex)
    {
        @throw ex;
    }
}

+ (NSDictionary *) PutRequest:(NSString *)URLString With:(NSDictionary *)parameters
{
    Arena  *arena=[Arena getInstance];
    NSString *url=[NSString stringWithFormat:@"%@%@",arena.baseURL, URLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:url]];
    NSString *authorization = [NSString stringWithFormat:@"Bearer %@",arena.access_token];
    
    NSString *post = [self serializeParams:parameters];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    [request setValue:authorization forHTTPHeaderField:@"Authorization"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"PUT"];
    
    @try
    {
        NSURLResponse *serverResponse;
        NSError *myError = nil;
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&serverResponse error:&myError];
        
        if (myError!=nil)
        {
            return nil;
        }
        
        if ( returnData == nil) {
            return nil;
        }
        
        NSError *serializeError = nil;
        
        NSMutableDictionary  *serializedResponse = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:&serializeError];
        
        return serializedResponse;
    }
    @catch (NSException *ex)
    {
        @throw ex;
    }
}

+ (NSDictionary *) DeleteRequest:(NSString *)URLString
{
    Arena  *arena=[Arena getInstance];
    NSString *url=[NSString stringWithFormat:@"%@%@",arena.baseURL, URLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:url]];
    
    NSString *authorization = [NSString stringWithFormat:@"Bearer %@",arena.access_token];
    
    [request setValue:authorization forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"DELETE"];
    
    @try
    {
        NSURLResponse *serverResponse;
        NSError *myError = nil;
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&serverResponse error:&myError];
        
        if (myError!=nil)
        {
            return nil;
        }
        if ( returnData == nil) {
            return nil;
        }
        
        NSError *serializeError = nil;
        
        NSMutableDictionary  *serializedResponse = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:&serializeError];
        
        return serializedResponse;
    }
    @catch (NSException *ex)
    {
        @throw ex;
    }
}

+ (NSDictionary *) DeleteRequest:(NSString *)URLString With:(NSDictionary *)parameters
{
    Arena  *arena=[Arena getInstance];
    NSString *url=[NSString stringWithFormat:@"%@%@",arena.baseURL, URLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:url]];
    NSString *authorization = [NSString stringWithFormat:@"Bearer %@",arena.access_token];
    
    NSString *post = [self serializeParams:parameters];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    [request setValue:authorization forHTTPHeaderField:@"Authorization"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"DELETE"];
    
    @try
    {
        NSURLResponse *serverResponse;
        NSError *myError = nil;
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&serverResponse error:&myError];
        
        if (myError!=nil)
        {
            return nil;
        }
        
        if ( returnData == nil) {
            return nil;
        }
        
        NSError *serializeError = nil;
        
        NSMutableDictionary  *serializedResponse = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:&serializeError];
        
        return serializedResponse;
    }
    @catch (NSException *ex)
    {
        @throw ex;
    }

}

+ (NSDictionary *) PostMulipartFormData:(NSString *)URLString With:(NSData *)formData
{
    Arena  *arena=[Arena getInstance];
    NSString *url=[NSString stringWithFormat:@"%@%@",arena.baseURL, URLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:url]];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];

    // TO DO
    // SETUP BODY DATA FOR UPLOAD HERE
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPMethod:@"POST"];
    NSURLResponse *serverResponse;
    NSError *myError = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&serverResponse error:&myError];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)serverResponse;
    int statusCode = [httpResponse statusCode];
    
    if (statusCode>=200)
    {
        
        myError=nil;
        NSMutableDictionary  *res = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:&myError];
        if (res!=nil && [res count]>0)
        {
            
        }
        return  res;
    }
    return nil;

}

#pragma mark Channel Methods

+ (NSDictionary *) GetChannelById:(NSString *)channelId
{
    NSString *url=[NSString stringWithFormat:@"channels/%@",channelId];
    NSDictionary *response=[self GetRequest:url];
    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) GetChannelBySlug:(NSString *)channelSlug
{
    NSString *url=[NSString stringWithFormat:@"channels/%@",channelSlug];
    NSDictionary *response=[self GetRequest:url];
    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) GetChannelThumb:(NSString *)channelSlug
{
    NSString *url=[NSString stringWithFormat:@"channels/%@/thumb",channelSlug];
    NSDictionary *response=[self GetRequest:url];
    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) GetChannelConnections:(NSString *)channelId
{
    NSString *url=[NSString stringWithFormat:@"channels/%@/connections",channelId];
    NSDictionary *response=[self GetRequest:url];
    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) GetConnectedChannels:(NSString *)channelId
{
    NSString *url=[NSString stringWithFormat:@"channels/%@/channels",channelId];
    NSDictionary *response=[self GetRequest:url];
    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) GetChannelContents:(NSString *)channelId
{
    NSString *url=[NSString stringWithFormat:@"channels/%@/contents",channelId];
    NSDictionary *response=[self GetRequest:url];
    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) CreateChannel:(NSString *)channelTitle
{
    NSString *url=[NSString stringWithFormat:@"channels"];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:channelTitle, @"title", nil];
    NSDictionary *response=[self PostRequest:url With:params];

    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) CreateChannelWith:(NSString *) channelTitle And:(NSString *)channelStatus{
    NSString *url=[NSString stringWithFormat:@"channels"];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:channelTitle, @"title", channelStatus, @"status", nil];
    NSDictionary *response=[self PostRequest:url With:params];
    
    if (response==nil) {
        return nil;
    }
    return response;
}


+ (NSDictionary *) UpdateChannelById:(NSString *)channelId With:(NSString *)channelTitle
{
    NSString *url=[NSString stringWithFormat:@"channels/%@",channelId];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:channelTitle, @"title", nil];
    NSDictionary *response=[self PutRequest:url With:params];
    
    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) UpdateChannelById:(NSString *)channelId With:(NSString *)channelTitle And:(NSString *)channelStatus
{
    NSString *url=[NSString stringWithFormat:@"channels/%@",channelId];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:channelTitle, @"title", channelStatus, @"status", nil];

    NSDictionary *response=[self PutRequest:url With:params];
    
    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) UpdateChannelBySlug:(NSString *)channelSlug With:(NSString *)channelTitle
{
    NSString *url=[NSString stringWithFormat:@"channels/%@",channelSlug];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:channelTitle, @"title", nil];
    NSDictionary *response=[self PutRequest:url With:params];
    
    if (response==nil) {
        return nil;
    }
    return response;
    
}

+ (NSDictionary *) SortChannelsById:(NSArray *)channelIds In:(NSString *)channelSlug
{
    
    NSString *url=[NSString stringWithFormat:@"channels/%@/sort", channelSlug];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:channelIds, @"ids", nil];
    NSDictionary *response=[self PutRequest:url With:params];
    
    if (response==nil) {
        return nil;
    }
    return response;

}

+ (NSDictionary *) DeleteChannelBySlug:(NSString *)channelSlug
{
    NSString *url=[NSString stringWithFormat:@"channels/%@",channelSlug];
    NSDictionary *response=[self DeleteRequest:url];
    
    if (response==nil) {
        return nil;
    }
    return response;
}

#pragma mark Collaborator Methods

+ (NSDictionary *) GetChannelCollaboratorsBySlug:(NSString *)channelSlug
{
    NSString *url=[NSString stringWithFormat:@"channels/%@/collaborators",channelSlug];
    NSDictionary *response=[self GetRequest:url];
    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) GetChannelCollaboratorsById:(NSString *)channelId
{
    NSString *url=[NSString stringWithFormat:@"channels/%@/collaborators",channelId];
    NSDictionary *response=[self GetRequest:url];
    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) CreateChannelCollaborators:(NSString *)channelId With:(NSArray *)collaboratorIds
{
    NSString *url=[NSString stringWithFormat:@"channels/%@/collaborators",channelId];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:collaboratorIds, @"ids", nil];
    NSDictionary *response=[self PostRequest:url With:params];
    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) DeleteChannelCollaborators:(NSString *)channelId With:(NSArray *)collaboratorIds
{
    NSString *url=[NSString stringWithFormat:@"channels/%@/collaborators",channelId];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:collaboratorIds, @"ids", nil];
    NSDictionary *response=[self DeleteRequest:url With:params];
    if (response==nil) {
        return nil;
    }
    return response;
}

#pragma mark Block Methods

+ (NSDictionary *) GetBlockById:(NSString *)blockId
{
    NSString *url=[NSString stringWithFormat:@"blocks/%@",blockId];
    NSDictionary *response=[self GetRequest:url];
    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) GetBlockChannelsById:(NSString *)blockId
{
    NSString *url=[NSString stringWithFormat:@"blocks/%@/channels",blockId];
    NSDictionary *response=[self GetRequest:url];
    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) CreateBlockByChannelSlug:(NSString *)channelSlug WithContent:(NSString *)content
{
    NSString *url=[NSString stringWithFormat:@"channels/%@/blocks",channelSlug];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:content, @"content", nil];
    NSDictionary *response=[self PostRequest:url With:params];
    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) CreateBlockByChannelSlug:(NSString *)channelSlug WithSource:(NSURL *)source
{
    NSString *url=[NSString stringWithFormat:@"channels/%@/blocks",channelSlug];
    NSString *sourceString= [source absoluteString];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:sourceString, @"source", nil];
    NSDictionary *response=[self PostRequest:url With:params];
    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) CreateBlockByChannelSlug:(NSString *)channelSlug WithImage:(UIImage *)image
{
    NSString *url=[NSString stringWithFormat:@"channels/%@/blocks",channelSlug];
    //TODO
}

+ (NSDictionary *) UpdateBlockTitleById:(NSString *)blockId With:(NSString *)title{
    NSString *url=[NSString stringWithFormat:@"blocks/%@",blockId];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:title, @"title", nil];
    NSDictionary *response=[self PutRequest:url With:params];
    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) UpdateBlockDescriptionById:(NSString *)blockId With:(NSString *)description{
    NSString *url=[NSString stringWithFormat:@"blocks/%@",blockId];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:description, @"description", nil];
    NSDictionary *response=[self PutRequest:url With:params];
    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) UpdateBlockContentById:(NSString *)blockId With:(NSString *)content
{
    NSString *url=[NSString stringWithFormat:@"blocks/%@",blockId];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:content, @"content", nil];
    NSDictionary *response=[self PutRequest:url With:params];
    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) DeleteBlockById:(NSString *)blockId WithChannelId:(NSString *)channelId
{
    NSString *url=[NSString stringWithFormat:@"channels/%@/blocks/%@",channelId, blockId];
    NSDictionary *response=[self DeleteRequest:url];
    if (response==nil) {
        return nil;
    }
    return response;
}

#pragma mark User Methods

+ (NSDictionary *) GetUserById:(NSString *)userId
{
    NSString *url=[NSString stringWithFormat:@"users/%@",userId];
    NSDictionary *response=[self GetRequest:url];
    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) GetUserChannelsById:(NSString *)userId
{
    NSString *url=[NSString stringWithFormat:@"users/%@/channels",userId];
    NSDictionary *response=[self GetRequest:url];
    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) GetUserChannelById:(NSString *)userId WithChannelId:(NSString *)channelId
{
    NSString *url=[NSString stringWithFormat:@"users/%@/channels/%@",userId, channelId];
    NSDictionary *response=[self GetRequest:url];
    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) GetUserFollowersById:(NSString *)userId
{
    NSString *url=[NSString stringWithFormat:@"users/%@/followers",userId];
    NSDictionary *response=[self GetRequest:url];
    if (response==nil) {
        return nil;
    }
    return response;
}

+ (NSDictionary *) GetUserFollowingById:(NSString *)userId
{
    NSString *url=[NSString stringWithFormat:@"users/%@/following",userId];
    NSDictionary *response=[self GetRequest:url];
    if (response==nil) {
        return nil;
    }
    return response;
}

@end
