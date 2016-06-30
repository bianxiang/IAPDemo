//
//  ViewController.m
//  IAP内购Demo
//
//  Created by xiaoxiao on 16/6/30.
//  Copyright © 2016年 xiaoxiao. All rights reserved.
//

#import "ViewController.h"

#import "IAPHelper.h"
#import "IAPShare.h"
#import <StoreKit/StoreKit.h>
#import "MJExtension.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *iapLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)touchBtn:(UIButton *)sender {
    
    NSLog(@"开始请求...");
    self.iapLabel.text = @"正在验证商品信息...";
    
    if(![IAPShare sharedHelper].iap) {
        NSSet* dataSet = [[NSSet alloc] initWithObjects:@"com.test.good1", nil];
        
        [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
    }
    
    [IAPShare sharedHelper].iap.production = NO;
    
    [[IAPShare sharedHelper].iap requestProductsWithCompletion:^(SKProductsRequest* request,SKProductsResponse* response)
     {
         if(response > 0 ) {
             SKProduct* product =[[IAPShare sharedHelper].iap.products objectAtIndex:0];
             NSLog(@"商品信息 -> %@",product.mj_keyValues);
//             product.mj_JSONString
             self.iapLabel.text = [NSString stringWithFormat:@"商品信息 -> \n%@",product.mj_JSONString];
             [[IAPShare sharedHelper].iap buyProduct:product
                                        onCompletion:^(SKPaymentTransaction* trans){
                                            
                                            if(trans.error)
                                            {
                                                NSLog(@"此处错误");
                                                NSLog(@"Fail %@",[trans.error localizedDescription]);
                                                self.iapLabel.text = [trans.error localizedDescription];
                                                
                                            }
                                            else if(trans.transactionState == SKPaymentTransactionStatePurchased) {
                                                
                                                [[IAPShare sharedHelper].iap checkReceipt:trans.transactionReceipt AndSharedSecret:@"912bb173d02c46dfabfea25f63f493b6" onCompletion:^(NSString *response, NSError *error) {
                                                    
                                                    //Convert JSON String to NSDictionary
                                                    NSDictionary* rec = [IAPShare toJSON:response];
                                                    
                                                    if([rec[@"status"] integerValue]==0)
                                                    {
                                                        NSLog(@"购买成功");
                                                        self.iapLabel.text = @"购买成功";
                                                        [[IAPShare sharedHelper].iap provideContentWithTransaction:trans];
                                                        NSLog(@"SUCCESS %@",response);
                                                        NSLog(@"Pruchases %@",[IAPShare sharedHelper].iap.purchasedProducts);
                                                        
                                                        self.iapLabel.text = [NSString stringWithFormat:@"SUCCESS %@ \nPruchases %@",response,[IAPShare sharedHelper].iap.purchasedProducts];
                                                        
                                                    }
                                                    else {
                                                        NSLog(@"Fail");
                                                        self.iapLabel.text = @"Fail";
                                                    }
                                                }];
                                            }
                                            else if(trans.transactionState == SKPaymentTransactionStateFailed) {
                                                NSLog(@"Fail");
                                                self.iapLabel.text = @"Fail";
                                            }
                                        }];//end of buy product
         }
     }];
}


@end


/*
 有关返回内容
 商品信息 -> {
	priceLocale = {
 },
	downloadable = 0,
	productIdentifier = com.test.good1,
	price = 1,
	localizedDescription = 卞翔的商品watch卞翔的商品watch,
	localizedTitle = 卞翔的商品watch
 }
 
 
 SUCCESS {
    "receipt":{"original_purchase_date_pst":"2016-06-30 03:52:57 America/Los_Angeles", "purchase_date_ms":"1467283977521", "unique_identifier":"5dcf6ca06b50549f0102766eb285108c7ef817fb", "original_transaction_id":"1000000220844594", "bvrs":"1", "transaction_id":"1000000220844594", "quantity":"1", "unique_vendor_identifier":"CF0A8049-5A43-474D-8F6D-0808AAE1E6E5", "item_id":"1129594388", "product_id":"com.test.good1", "purchase_date":"2016-06-30 10:52:57 Etc/GMT", "original_purchase_date":"2016-06-30 10:52:57 Etc/GMT", "purchase_date_pst":"2016-06-30 03:52:57 America/Los_Angeles", "bid":"com.bianxiang.watch", "original_purchase_date_ms":"1467283977521"}, "status":0}
2016-06-30 18:52:59.634 IAP内购Demo[233:6932] Pruchases {(
                                                        "com.test.good1"
                                                        )}
 
 */
