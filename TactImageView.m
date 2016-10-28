//
//  TactImageView.m
//
//  Version 1.5.1
//
//  Created by Nick Lockwood on 03/04/2011.
//  Copyright (c) 2011 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/TactImageView
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//


#import "TactImageView.h"
#import <objc/message.h>
#import <QuartzCore/QuartzCore.h>


#import <Availability.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wobjc-missing-property-synthesis"




NSString *const TactImageLoadDidFinish = @"TactImageLoadDidFinish";
NSString *const TactImageLoadDidFail = @"TactImageLoadDidFail";

NSString *const TactImageImageKey = @"image";
NSString *const TactImageURLKey = @"URL";
NSString *const TactImageCacheKey = @"cache";
NSString *const TactImageErrorKey = @"error";



@interface TactImageLoader : NSObject

+ (TactImageLoader *)sharedLoader;
+ (NSCache *)defaultCache;

@property (nonatomic, strong) NSCache *cache;
@property (nonatomic, assign) NSUInteger concurrentLoads;
@property (nonatomic, assign) NSTimeInterval loadingTimeout;

- (void)loadImageWithURL:(NSURL *)URL target:(id)target success:(SEL)success failure:(SEL)failure;
- (void)loadImageWithURL:(NSURL *)URL target:(id)target action:(SEL)action;
- (void)loadImageWithURL:(NSURL *)URL;
- (void)cancelLoadingURL:(NSURL *)URL target:(id)target action:(SEL)action;
- (void)cancelLoadingURL:(NSURL *)URL target:(id)target;
- (void)cancelLoadingURL:(NSURL *)URL;
- (void)cancelLoadingImagesForTarget:(id)target action:(SEL)action;
- (void)cancelLoadingImagesForTarget:(id)target;
- (NSURL *)URLForTarget:(id)target action:(SEL)action;
- (NSURL *)URLForTarget:(id)target;

@end


@interface TactImageConnection : NSObject

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSCache *cache;
@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL success;
@property (nonatomic, assign) SEL failure;
@property (nonatomic, getter = isLoading) BOOL loading;
@property (nonatomic, getter = isCancelled) BOOL cancelled;

- (TactImageConnection *)initWithURL:(NSURL *)URL
                                cache:(NSCache *)cache
							   target:(id)target
							  success:(SEL)success
							  failure:(SEL)failure;

- (void)start;
- (void)cancel;
- (BOOL)isInCache;

@end


@implementation TactImageConnection

- (TactImageConnection *)initWithURL:(NSURL *)URL
                                cache:(NSCache *)cache
							   target:(id)target
							  success:(SEL)success
							  failure:(SEL)failure
{
    if ((self = [self init]))
    {
        self.URL = URL;
        self.cache = cache;
        self.target = target;
        self.success = success;
        self.failure = failure;
    }
    return self;
}

- (UIImage *)cachedImage
{
    if ([self.URL isFileURL])
	{
		NSString *path = [[self.URL absoluteURL] path];
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
		if ([path hasPrefix:resourcePath])
		{
			return [UIImage imageNamed:[path substringFromIndex:[resourcePath length]]];
		}
	}
    return [self.cache objectForKey:self.URL];
}

- (BOOL)isInCache
{
    return [self cachedImage] != nil;
}

- (void)loadFailedWithError:(NSError *)error
{
	self.loading = NO;
	self.cancelled = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:TactImageLoadDidFail
                                                        object:self.target
                                                      userInfo:@{TactImageURLKey: self.URL,
                                                                TactImageErrorKey: error}];
}

- (void)cacheImage:(UIImage *)image
{
	if (!self.cancelled)
	{
        if (image && self.URL)
        {
            BOOL storeInCache = YES;
            if ([self.URL isFileURL])
            {
                if ([[[self.URL absoluteURL] path] hasPrefix:[[NSBundle mainBundle] resourcePath]])
                {
                    //do not store in cache
                    storeInCache = NO;
                }
            }
            if (storeInCache)
            {
                [self.cache setObject:image forKey:self.URL];
            }
        }
        
		NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										 image, TactImageImageKey,
										 self.URL, TactImageURLKey,
										 nil];
		if (self.cache)
		{
			userInfo[TactImageCacheKey] = self.cache;
		}
		
		self.loading = NO;
		[[NSNotificationCenter defaultCenter] postNotificationName:TactImageLoadDidFinish
															object:self.target
														  userInfo:[userInfo copy]];
	}
	else
	{
		self.loading = NO;
		self.cancelled = NO;
	}
}

- (void)processDataInBackground:(NSData *)data
{
	@synchronized ([self class])
	{	
		if (!self.cancelled)
		{
            UIImage *image = [[UIImage alloc] initWithData:data];
			if (image)
			{
                //redraw to prevent deferred decompression
                UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
                [image drawAtPoint:CGPointZero];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
				//add to cache (may be cached already but it doesn't matter)
                [self performSelectorOnMainThread:@selector(cacheImage:)
                                       withObject:image
                                    waitUntilDone:YES];
			}
			else
			{
                @autoreleasepool
                {
                    NSError *error = [NSError errorWithDomain:@"TactImageLoader" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Invalid image data"}];
                    [self performSelectorOnMainThread:@selector(loadFailedWithError:) withObject:error waitUntilDone:YES];
				}
			}
		}
		else
		{
			//clean up
			[self performSelectorOnMainThread:@selector(cacheImage:)
								   withObject:nil
								waitUntilDone:YES];
		}
	}
}

- (void)connection:(__unused NSURLConnection *)connection didReceiveResponse:(__unused NSURLResponse *)response
{
    self.data = [NSMutableData data];
}

- (void)connection:(__unused NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //add data
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(__unused NSURLConnection *)connection
{
    [self performSelectorInBackground:@selector(processDataInBackground:) withObject:self.data];
    self.connection = nil;
    self.data = nil;
}

- (void)connection:(__unused NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.connection = nil;
    self.data = nil;
    [self loadFailedWithError:error];
}

- (void)start
{
    if (self.loading && !self.cancelled)
    {
        return;
    }
	
	//begin loading
	self.loading = YES;
	self.cancelled = NO;
    
    //check for nil URL
    if (self.URL == nil)
    {
        [self cacheImage:nil];
        return;
    }
    
    //check for cached image
	UIImage *image = [self cachedImage];
    if (image)
    {
        //add to cache (cached already but it doesn't matter)
        [self performSelectorOnMainThread:@selector(cacheImage:)
                               withObject:image
                            waitUntilDone:NO];
        return;
    }
    
    //begin load
    NSURLRequest *request = [NSURLRequest requestWithURL:self.URL
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:[TactImageLoader sharedLoader].loadingTimeout];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [self.connection start];
}

- (void)cancel
{
	self.cancelled = YES;
    [self.connection cancel];
    self.connection = nil;
    self.data = nil;
}

@end


@interface TactImageLoader ()

@property (nonatomic, strong) NSMutableArray *connections;

@end


@implementation TactImageLoader

+ (TactImageLoader *)sharedLoader
{
	static TactImageLoader *sharedInstance = nil;
	if (sharedInstance == nil)
	{
		sharedInstance = [(TactImageLoader *)[self alloc] init];
	}
	return sharedInstance;
}

+ (NSCache *)defaultCache
{
    static NSCache *sharedCache = nil;
	if (sharedCache == nil)
	{
		sharedCache = [[NSCache alloc] init];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(__unused NSNotification *note) {
            
            [sharedCache removeAllObjects];
        }];
	}
	return sharedCache;
}

- (TactImageLoader *)init
{
	if ((self = [super init]))
	{
        self.cache = [[self class] defaultCache];
        _concurrentLoads = 2;
        _loadingTimeout = 60.0;
		_connections = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(imageLoaded:)
													 name:TactImageLoadDidFinish
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(imageFailed:)
													 name:TactImageLoadDidFail
												   object:nil];
	}
	return self;
}

- (void)updateQueue
{
    //start connections
    NSUInteger count = 0;
    for (TactImageConnection *connection in self.connections)
    {
        if (![connection isLoading])
        {
            if ([connection isInCache])
            {
                [connection start];
            }
            else if (count < self.concurrentLoads)
            {
                count ++;
                [connection start];
            }
        }
    }
}

- (void)imageLoaded:(NSNotification *)notification
{  
    //complete connections for URL
    NSURL *URL = (notification.userInfo)[TactImageURLKey];
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        TactImageConnection *connection = self.connections[(NSUInteger)i];
        if (connection.URL == URL || [connection.URL isEqual:URL])
        {
            //cancel earlier connections for same target/action
            for (NSInteger j = i - 1; j >= 0; j--)
            {
                TactImageConnection *earlier = self.connections[(NSUInteger)j];
                if (earlier.target == connection.target &&
                    earlier.success == connection.success)
                {
                    [earlier cancel];
                    [self.connections removeObjectAtIndex:(NSUInteger)j];
                    i--;
                }
            }
            
            //cancel connection (in case it's a duplicate)
            [connection cancel];
            
            //perform action
			UIImage *image = (notification.userInfo)[TactImageImageKey];
            ((void (*)(id, SEL, id, id))objc_msgSend)(connection.target, connection.success, image, connection.URL);
            
            //remove from queue
            [self.connections removeObjectAtIndex:(NSUInteger)i];
        }
    }
    
    //update the queue
    [self updateQueue];
}

- (void)imageFailed:(NSNotification *)notification
{
    //remove connections for URL
    NSURL *URL = (notification.userInfo)[TactImageURLKey];
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        TactImageConnection *connection = self.connections[(NSUInteger)i];
        if ([connection.URL isEqual:URL])
        {
            //cancel connection (in case it's a duplicate)
            [connection cancel];
            
            //perform failure action
            if (connection.failure)
            {
                NSError *error = (notification.userInfo)[TactImageErrorKey];
                ((void (*)(id, SEL, id, id))objc_msgSend)(connection.target, connection.failure, error, URL);
            }
            
            //remove from queue
            [self.connections removeObjectAtIndex:(NSUInteger)i];
        }
    }
    
    //update the queue
    [self updateQueue];
}

- (void)loadImageWithURL:(NSURL *)URL target:(id)target success:(SEL)success failure:(SEL)failure
{
    //check cache
    UIImage *image = [self.cache objectForKey:URL];
    if (image)
    {
        [self cancelLoadingImagesForTarget:self action:success];
        if (success)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                ((void (*)(id, SEL, id, id))objc_msgSend)(target, success, image, URL);
            });
        }
        return;
    }
    
    //create new connection
    TactImageConnection *connection = [[TactImageConnection alloc] initWithURL:URL
                                                                           cache:self.cache
                                                                          target:target
                                                                         success:success
                                                                         failure:failure];
    BOOL added = NO;
    for (NSUInteger i = 0; i < [self.connections count]; i++)
    {
        TactImageConnection *existingConnection = self.connections[i];
        if (!existingConnection.loading)
        {
            [self.connections insertObject:connection atIndex:i];
            added = YES;
            break;
        }
    }
    if (!added)
    {
        [self.connections addObject:connection];
    }
    
    [self updateQueue];
}

- (void)loadImageWithURL:(NSURL *)URL target:(id)target action:(SEL)action
{
    [self loadImageWithURL:URL target:target success:action failure:NULL];
}

- (void)loadImageWithURL:(NSURL *)URL
{
    [self loadImageWithURL:URL target:nil success:NULL failure:NULL];
}

- (void)cancelLoadingURL:(NSURL *)URL target:(id)target action:(SEL)action
{
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        TactImageConnection *connection = self.connections[(NSUInteger)i];
        if ([connection.URL isEqual:URL] && connection.target == target && connection.success == action)
        {
            [connection cancel];
            [self.connections removeObjectAtIndex:(NSUInteger)i];
        }
    }
}

- (void)cancelLoadingURL:(NSURL *)URL target:(id)target
{
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        TactImageConnection *connection = self.connections[(NSUInteger)i];
        if ([connection.URL isEqual:URL] && connection.target == target)
        {
            [connection cancel];
            [self.connections removeObjectAtIndex:(NSUInteger)i];
        }
    }
}

- (void)cancelLoadingURL:(NSURL *)URL
{
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        TactImageConnection *connection = self.connections[(NSUInteger)i];
        if ([connection.URL isEqual:URL])
        {
            [connection cancel];
            [self.connections removeObjectAtIndex:(NSUInteger)i];
        }
    }
}

- (void)cancelLoadingImagesForTarget:(id)target action:(SEL)action
{
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        TactImageConnection *connection = self.connections[(NSUInteger)i];
        if (connection.target == target && connection.success == action)
        {
            [connection cancel];
        }
    }
}

- (void)cancelLoadingImagesForTarget:(id)target
{
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        TactImageConnection *connection = self.connections[(NSUInteger)i];
        if (connection.target == target)
        {
            [connection cancel];
        }
    }
}

- (NSURL *)URLForTarget:(id)target action:(SEL)action
{
    //return the most recent image URL assigned to the target for the given action
    //this is not neccesarily the next image that will be assigned
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        TactImageConnection *connection = self.connections[(NSUInteger)i];
        if (connection.target == target && connection.success == action)
        {
            return connection.URL;
        }
    }
    return nil;
}

- (NSURL *)URLForTarget:(id)target
{
    //return the most recent image URL assigned to the target
    //this is not neccesarily the next image that will be assigned
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        TactImageConnection *connection = self.connections[(NSUInteger)i];
        if (connection.target == target)
        {
            return connection.URL;
        }
    }
    return nil;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


@implementation UIImageView(TactImageView)

- (void)setImageURL:(NSURL *)imageURL
{
	[[TactImageLoader sharedLoader] loadImageWithURL:imageURL target:self action:@selector(setImage:)];
}

- (void)setImageneryURL:(NSURL *)imageneryURL{
    [[TactImageLoader sharedLoader] loadImageWithURL:imageneryURL target:self action:@selector(setImage:)];
}


- (NSURL *)imageURL
{
    return [[TactImageLoader sharedLoader] URLForTarget:self action:@selector(setImage:)];
}

- (NSURL *)imageneryURL
{
	return [[TactImageLoader sharedLoader] URLForTarget:self action:@selector(setImage:)];
}

@end


@interface TactImageView ()

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end


@implementation TactImageView

- (void)setUp
{
	self.showActivityIndicator = (self.image == nil);
	self.activityIndicatorStyle = UIActivityIndicatorViewStyleGray;
	self.crossfadeDuration = 0.4;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setUp];
    }
    return self;
}

- (void)setImageURL:(NSURL *)imageURL
{
    UIImage *image = [[TactImageLoader sharedLoader].cache objectForKey:imageURL];
    if (image)
    {
        self.image = image;
        return;
    }
    super.imageURL = imageURL;
    if (self.showActivityIndicator && !self.image && imageURL)
    {
        if (self.activityView == nil)
        {
            self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:self.activityIndicatorStyle];
            self.activityView.hidesWhenStopped = YES;
            self.activityView.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
            self.activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
            [self addSubview:self.activityView];
        }
        [self.activityView startAnimating];
    }
}


-(void) setImageneryURL:(NSURL *)imageneryURL
{
 
    
    
    UIImage *image = [[TactImageLoader sharedLoader].cache objectForKey:imageneryURL];
    if (image)
    {
        self.image = image;
        return;
    }
    super.imageneryURL = imageneryURL;
    if ( self.showActivityIndicator && !self.image && imageneryURL)
    {
      
        
        
        if (self.activityView == nil)
        {
            self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:self.activityIndicatorStyle];
            self.activityView.hidesWhenStopped = YES;
            self.activityView.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
            self.activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
            [self addSubview:self.activityView];
            self.image = [UIImage imageNamed:@"placeholder.png"];
        }
        [self.activityView startAnimating];
    }
}

- (void)setActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style
{
	_activityIndicatorStyle = style;
	[self.activityView removeFromSuperview];
	self.activityView = nil;
}

- (void)setImage:(UIImage *)image
{
    if (image != self.image && self.crossfadeDuration)
    {
        //jump through a few hoops to avoid QuartzCore framework dependency
        CAAnimation *animation = [NSClassFromString(@"CATransition") animation];
        [animation setValue:@"kCATransitionFade" forKey:@"type"];
        animation.duration = self.crossfadeDuration;
        [self.layer addAnimation:animation forKey:nil];
    }
    super.image = image;
    [self.activityView stopAnimating];
}

- (void)dealloc
{
    [[TactImageLoader sharedLoader] cancelLoadingURL:self.imageURL target:self];
    [[TactImageLoader sharedLoader] cancelLoadingURL:self.imageneryURL target:self];
}

@end
