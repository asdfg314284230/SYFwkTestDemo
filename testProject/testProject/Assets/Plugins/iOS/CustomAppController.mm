
#import "UnityAppController.h"
// #import "AVFoundation/AvAudioSession.h"
// #import <XGame/XGame.h>
// #import <UMCommon/UMCommon.h>
// #import <UMAnalytics/MobClick.h>
// #import <UMAnalytics/MobClickGameAnalytics.h>
// #import "ViewController.h"
// #import "VodPlayer.h"

// UIViewController * uiViewController;

extern "C"
{
    extern void zzp_playback_suspend(bool set);
    // 给Unity3d调用的方法
    void ios_init_sdk(const char* data)
    {
        //程序启动时 初始化SDK
        NSString * jsonStr = [NSString stringWithUTF8String:data];
        // 将json字符串转换成字典
        NSError * error = nil;
        NSData * getJsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:getJsonData options:NSJSONReadingMutableContainers error:&error];
        for (NSString *key in dict) {
            NSLog(@"%@:%@",key,dict[key]);
        }
        BOOL isAu = NO;
        if ([dict[@"isAu"] intValue] == 1)
        {
            isAu = YES;
        }
        
        NSLog(@"isAu=%@",isAu?@"YES":@"NO");
        
        // [[XGame defaultGame]setLifuWuQi:isAu];
        
        //友盟
        // NSString * youmeng_key = dict[@"youmeng_key"];
        // NSString * youmeng_channel = dict[@"youmeng_channel"];
        // NSLog(@"youmeng_key=%@",youmeng_key);
        // NSLog(@"youmeng_channel=%@",youmeng_channel);
        // //[UNUMConfigure initWithAppkey:youmeng_key channel:youmeng_channel];
        // [UMConfigure initWithAppkey:youmeng_key channel:youmeng_channel];
        // [MobClick setScenarioType:E_UM_GAME];
        // [UMConfigure setLogEnabled:YES];
    }
    
    // void ios_analytics_event(const char* eventId, const char* data)
    // {
    //     NSString * eventIdStr = [NSString stringWithUTF8String:eventId];
    //     if(data != NULL)
    //     {
    //         NSString * jsonStr = [NSString stringWithUTF8String:data];
    //         // 将json字符串转换成字典
    //         NSError * error = nil;
    //         NSData * getJsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    //         NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:getJsonData options:NSJSONReadingMutableContainers error:&error];
         
    //         [MobClick event:eventIdStr attributes:dict];
    //     }
    //     else
    //     {
    //         [MobClick event:eventIdStr];
    //     }
    // }
    
//     void ios_analytics_pay(const char* data)
//     {
//         NSString * jsonStr = [NSString stringWithUTF8String:data];
//         // 将json字符串转换成字典
//         NSError * error = nil;
//         NSData * getJsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
//         NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:getJsonData options:NSJSONReadingMutableContainers error:&error];
//         [MobClickGameAnalytics pay:[dict[@"cash"] doubleValue] source:[dict[@"source"] intValue] coin:[dict[@"coin"] doubleValue]];
     
//     }
    
//     bool ios_is_platform_login()
//     {
//         return YES;
//     }
    
    
//     bool ios_isSupportLogout()
//     {
//         return YES;
//     }
    
    
//     bool ios_isSupportAccountCenter()
//     {
//         return NO;
//     }
    
    // 登陆
     void ios_login(const char* data)
     {
         NSLog(@"ios_login");
        // 讲获取的的东西转换成Json字符串
        NSString * jsonStr = [NSString stringWithUTF8String:data];
        // 将json字符串转换成字典
        // NSError * error = nil;
        // NSData * getJsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        // NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:getJsonData options:NSJSONReadingMutableContainers error:&error];

        // 登陆完了，默认登陆成功，返回数数据
        UnitySendMessage("sdk", "platform_msg", [jsonStr UTF8String]);

         //        [[QaToGame sharedSdk] openLg];
         // [XGame gameLogin];
     }
    
    
//     void ios_logout()
//     {
//         [XGame gameLogout];
//     }
    
//     void ios_showAccountCenter()
//     {
//         //        [[QaToGame sharedSdk] toAccountCenter];//打开用户中心
//     }
    
//     void ios_submitExtraData(const char* data)
//     {
//         NSLog(@"ios_submitExtraData");
//         NSLog(@"%s",data);
//         NSString * jsonStr = [NSString stringWithUTF8String:data];
//         // 将json字符串转换成字典
//         NSError * error = nil;
//         NSData * getJsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
//         NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:getJsonData options:NSJSONReadingMutableContainers error:&error];
//         for (NSString *key in dict) {
//             NSLog(@"%@:%@",key,dict[key]);
//         }
     
//         [[XGame defaultGame]submitType:[dict[@"callType"] intValue]
//                               serverid:dict[@"serverID"]
//                                 zoneid:dict[@"zoneId"]
//                                 roleid:dict[@"roleID"]
//                             serverName:dict[@"serverName"]
//                               zoneName:dict[@"zoneName"]
//                               roleName:dict[@"roleName"]
//                              roleLevel:dict[@"roleLevel"]];
//     }
    
//     void ios_exit()
//     {
        
//     }
    
//     void ios_purchase(const char* data)
//     {
        
//         NSLog(@"ios_purchase");
//         NSLog(@"%s",data);
        
//         NSString * jsonStr = [NSString stringWithUTF8String:data];
        
//         // 将json字符串转换成字典
//         NSError * error = nil;
//         NSData * getJsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
//         NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:getJsonData options:NSJSONReadingMutableContainers error:&error];
//         for (NSString *key in dict) {
//             NSLog(@"%@:%@",key,dict[key]);
            
//         }
   
//         [[XGame defaultGame] buyPrice:[NSString stringWithFormat:@"%d",[dict[@"price"] intValue]*100]
//                                   ext:dict[@"extension"]
//                              callback:dict[@"notifyUrl"]
//                             prodoutId:dict[@"productId"]
//                              serverid:dict[@"serverid"]
//                                zoneid:dict[@"zoneid"]
//                                roleid:dict[@"roleid"]
//                            serverName:dict[@"serverName"]
//                              roleName:dict[@"roleName"]
//                             roleLevel:dict[@"roleLevel"]
//                           prodoutName:dict[@"productName"]];
        
//     }
    
//     int ios_getCurrChannel()
//     {
//         return 1;
//     }
	
// 	bool ios_video_support()
//     {
// 		NSLog(@"ios_video_support");
//         return YES;
//     }

//     void ios_video_clear()
//     {
//         NSLog(@"ios_video_clear");
//         // [[AliyunVodDownLoadManager shareManager] clearAllMedias];
//     }

//     void ios_video_play(const char* data){
//         NSLog(@"ios_video_play data = %s", data);
        
//         NSString *jsonStr = [NSString stringWithUTF8String:data];
//         NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
//         NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
//         for (NSString* key in dict) {
//             NSLog(@"%@:%@", key, dict[key]);
//         }
        
//         NSString *videoName = dict[@"videoName"];
//         int orientation = [dict[@"orientation"] intValue];
//         VodPlayer *vodPlayer = [VodPlayer sharedVodPlayer];
//         [vodPlayer playVideo:videoName orientation:(VideoOrientation)orientation];
//     }
    
//     void ios_video_branch(const char* data){
//         NSLog(@"ios_video_branch data = %s", data);
        
//         NSString *jsonStr = [NSString stringWithUTF8String:data];
//         NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
//         NSArray *arr = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
//         for (int i = 0; i < arr.count; i++) {
//             NSLog(@"arr[%d] = %@", i, arr[i]);
//         }
//         VodPlayer *vodPlayer = [VodPlayer sharedVodPlayer];
//         [vodPlayer showBranch:arr];
//     }
    
//     void ios_video_destroy(){
//         NSLog(@"ios_video_destroy");
        
//         VodPlayer *vodPlayer = [VodPlayer sharedVodPlayer];
//         [vodPlayer destroyPlayer];
//     }
// }

@interface CustomAppController : UnityAppController

@end

IMPL_APP_CONTROLLER_SUBCLASS (CustomAppController)

@implementation CustomAppController

//- (void)willStartWithViewController:(UIViewController*)controller {
    // 新建自定义视图控制器。
//    ViewController *viewController = [[ViewController alloc] init];
    
    // 把Unity的内容视图作为子视图放到我们自定义的视图里面。
//    [viewController.view addSubview:(UIView*)_unityView];
    
    //VodPlayer *vodPlayer = [VodPlayer sharedVodPlayer];
    //[vodPlayer setParentView:viewController.view];
    
    // [vodPlayer playVideo:@"" orientation:VideoOrientationPortrait];
    
    // 把根视图和控制器全部换成我们自定义的内容。
    //_rootController = viewController;
    //_rootView = viewController.view;
//}

 - (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
 {
     [super application:application didFinishLaunchingWithOptions:launchOptions];
    
//     uiViewController = self.rootViewController;
    
     /*
     [Bugly startWithAppId:@"cbdab3883c"];
     */
//     [XGame application:application didFinishLaunchingWithOptions:launchOptions successed:^(NSObject *data, int code) {
//         NSLog(@"%@ %d",data,code);
     
//         if (code == 2)
//         {
//             //登陆成功
//             NSLog(@"onLoginSuccess");
//             NSDictionary *d = data;
//             NSDictionary *session = d[@"session"];
//             NSDictionary *user = d[@"user"];
//             NSLog(@"user = %@" , user[@"a"]);
//             NSLog(@"token = %@" , session[@"a"]);
//
//
//             // 字典转换成Json字符串
//             NSDictionary * dict = @{
//                                     @"type": @"login",
//                                     @"result": @"success",        //success fail
//                                     @"user_id":user[@"a"],   //渠道用户id
//                                     @"token":session[@"a"],     //Token
//                                     @"game_id": @"1",           //游戏id
//                                     @"channal_id": @"ck",        //渠道id
//                                     };
//             NSError * error = nil;
//             NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
//             NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//             NSLog(@"jsonStr = %@" , jsonStr);
//             UnitySendMessage("sdk", "platform_msg", [jsonStr UTF8String]);
//         }
//         if (code == 3)
//         {
//             //登陆失败
//             NSLog(@"onLoginFail");
//             NSDictionary * dict = @{
//                                     @"type": @"login",
//                                     @"result": @"fail",        //success fail
//                                     };
//             NSError * error = nil;
//             NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
//             NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//             NSLog(@"jsonStr = %@" , jsonStr);
//             UnitySendMessage("sdk", "platform_msg", [jsonStr UTF8String]);
//         }
//         if (code == 4)
//         {
//             //支付成功
//             NSLog(@"onJoSucess");
//             NSLog(@"productID=%@", [NSString stringWithFormat:@"%@",data]);
//             // 字典转换成Json字符串
//             NSDictionary * dict = @{
//                                     @"type": @"purchase",
//                                     @"result": @"success",        //success fail
//                                     @"productID": [NSString stringWithFormat:@"%@",data],
//                                     };
//             NSError * error = nil;
//             NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
//             NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//             NSLog(@"jsonStr = %@" , jsonStr);
//             UnitySendMessage("sdk", "platform_msg", [jsonStr UTF8String]);
//         }
//
//         if (code == 5)
//         {
//             //支付失败
//             NSDictionary * dict = @{
//                                     @"type": @"purchase",
//                                     @"result": @"fail",        //success fail
//                                     };
//             NSError * error = nil;
//             NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
//             NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//             NSLog(@"jsonStr = %@" , jsonStr);
//             UnitySendMessage("sdk", "platform_msg", [jsonStr UTF8String]);
//         }
//
//         if (code == 6)
//         {
//             //注销成功
//             NSLog(@"onLogout");
//             // 字典转换成Json字符串
//             NSDictionary * dict = @{
//                                     @"type": @"logout",
//                                     @"result": @"success",        //success fail
//                                     };
//             NSError * error = nil;
//             NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
//             NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//             NSLog(@"jsonStr = %@" , jsonStr);
//             UnitySendMessage("sdk", "platform_msg", [jsonStr UTF8String]);
//         }
//
//     }];
//     //    [[QaToGame sharedSdk] initQa:nil gameVC:uiViewController delegate:self audi:isAu];
//
//     [[NSNotificationCenter defaultCenter] addObserver:self
//                                              selector:@selector(handleAudioSessionInterruption:)
//                                                  name:AVAudioSessionInterruptionNotification
//                                                object:[AVAudioSession sharedInstance]];
//
     return YES;
 }

 #pragma mark Interruption Handling

 - (void) handleAudioSessionInterruption: (NSNotification*) event
 {
//     NSUInteger type = [[[event userInfo] objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
//     switch (type) {
//         case AVAudioSessionInterruptionTypeBegan:
//             NSLog(@"Audio interruption began, suspending sound engine.");
//             //[_soundEngine setSuspended:YES];
//             zzp_playback_suspend(true);
//             break;
//         case AVAudioSessionInterruptionTypeEnded:
//             if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
//                 NSLog(@"Audio interruption ended, resuming sound engine.");
//                 //[_soundEngine setSuspended:NO];
//                 zzp_playback_suspend(false);
//             } else {
//                 // Have to wait for the app to become active, otherwise
//                 // the audio session won’t resume correctly.
//             }
//             break;
//     }
 }

 - (void) applicationDidBecomeActive: (UIApplication*) application
 {
     [super applicationDidBecomeActive:application];
     //if ([_soundEngine isSuspended]) {
     NSLog(@"Audio interruption ended while inactive, resuming sound engine now.");
     //[_soundEngine setSuspended:NO];
//     zzp_playback_suspend(false);
     //}
 }


@end
}
