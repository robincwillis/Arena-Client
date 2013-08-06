//
//  Arena.h
//  ArenaClient
//
//  Created by Robin Willis on 7/30/13.
//  Copyright (c) 2013 Robin Willis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Arena : NSObject

@property(nonatomic,retain) NSString *baseURL;
@property(nonatomic,retain) NSString *arenaAPI;
@property(nonatomic,retain) NSString *arenaURL;
@property(nonatomic,retain) NSString *access_token;

//Client
+ (Arena *) getInstance;
+ (void) SetToken:(NSString *)token;

+ (NSDictionary *) GetRequest:(NSString *)URLString;
+ (NSDictionary *) PostRequest:(NSString *)URLString With:(NSDictionary *)parameters;
+ (NSDictionary *) PutRequest:(NSString *)URLString With:(NSDictionary *)paremeters;
+ (NSDictionary *) DeleteRequest:(NSString *)URLString;
+ (NSDictionary *) DeleteRequest:(NSString *)URLString With:(NSDictionary *)parameters;

//Channels
+ (NSDictionary *) GetChannelById:(NSString *)channelId;
+ (NSDictionary *) GetChannelBySlug:(NSString *)channelSlug;
+ (NSDictionary *) GetChannelThumb:(NSString *)channelId;
+ (NSDictionary *) GetChannelConnections:(NSString *)channelId;
+ (NSDictionary *) GetConnectedChannels:(NSString *)channelId;
+ (NSDictionary *) GetChannelContents:(NSString *)channelId;
+ (NSDictionary *) CreateChannel:(NSString *)channelTitle;
+ (NSDictionary *) CreateChannelWith:(NSString *)channelTitle And:(NSString *)channelStatus;
+ (NSDictionary *) UpdateChannelById:(NSString *)channelId With:(NSString *)channelTitle;
+ (NSDictionary *) UpdateChannelById:(NSString *)channelId With:(NSString *)channelTitle And:(NSString *)channelStatus;
+ (NSDictionary *) UpdateChannelBySlug:(NSString *)channelSlug With:(NSString *)channelTitle;
+ (NSDictionary *) SortChannelsById:(NSArray *)channelIds;
+ (NSDictionary *) DeleteChannelBySlug:(NSString *)channelSlug;

//Collaborators
+ (NSDictionary *) GetChannelCollaboratorsBySlug:(NSString *)channelSlug;
+ (NSDictionary *) GetChannelCollaboratorsById:(NSString *)channelId;
+ (NSDictionary *) CreateChannelCollaborators:(NSString *)channelId With:(NSArray *)collaboratorIds;
+ (NSDictionary *) DeleteChannelCollaborators:(NSString *)channelId With:(NSArray *)collaboratorIds;

//Blocks
+ (NSDictionary *) GetBlockById:(NSString *)blockId;
+ (NSDictionary *) GetBlockChannelsById:(NSString *)blockId;

+ (NSDictionary *) CreateBlockByChannelSlug:(NSString *)channelSlug WithContent:(NSString *)content;
+ (NSDictionary *) CreateBlockByChannelSlug:(NSString *)channelSlug WithSource:(NSURL *)source;
+ (NSDictionary *) CreateBlockByChannelSlug:(NSString *)channelSlug WithImage:(UIImage *)image;
+ (NSDictionary *) UpdateBlockTitleById:(NSString *)blockId With:(NSString *)title;
+ (NSDictionary *) UpdateBlockDescriptionById:(NSString *)blockId With:(NSString *)description;
+ (NSDictionary *) UpdateBlockContentById:(NSString *)blockId With:(NSString *)content;
+ (NSDictionary *) DeleteBlockById:(NSString *)blockId WithChannelId:(NSString *)channelId;

//Users
+ (NSDictionary *) GetUserById:(NSString *)userId;
+ (NSDictionary *) GetUserChannelsById:(NSString *)userId;
+ (NSDictionary *) GetUserChannelById:(NSString *)userId WithChannelId:(NSString *)channelId;
+ (NSDictionary *) GetUserFollowersById:(NSString *)userId;
+ (NSDictionary *) GetUserFollowingById:(NSString *)userId;

@end