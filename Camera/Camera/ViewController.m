//
//  ViewController.m
//  Camera
//
//  Created by linxiu on 16/5/20.
//  Copyright © 2016年 甘真辉. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak,nonatomic) IBOutlet UIImageView *imageView;
@property (weak,nonatomic) IBOutlet UIButton *takePictureButton;

@property (strong,nonatomic) MPMoviePlayerController *moviePlayerController;
@property (strong,nonatomic) UIImage *image;
@property (strong,nonatomic) NSURL *movieURL;
@property (copy,nonatomic) NSString *lastChosenMediaType;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) { //判断设备有没有摄像头
        
        self.takePictureButton.hidden = YES; //没有摄像头就隐藏拍照的按钮
    }
}
-(void)viewDidAppear:(BOOL)animated{ //每次显示视图都会被调用
    [super viewDidAppear:animated];
    
    [self updateDisplay];
}
-(void)updateDisplay{

    if (![self.lastChosenMediaType isEqual:(NSString *)kUTTypeImage]) { //判断选择类型的是图像
        
        self.imageView.image = self.image;
        self.imageView.hidden = NO;
        self.moviePlayerController.view.hidden = YES;
        
    }else if ([self.lastChosenMediaType isEqual:(NSString *)kUTTypeMovie]){//判断选择类型的是视频
    
        [self.moviePlayerController.view removeFromSuperview];
        self.moviePlayerController = [[MPMoviePlayerController alloc]initWithContentURL:self.movieURL];
        [self.moviePlayerController play];
        
        UIView *movieView = self.moviePlayerController.view;
        movieView.frame = self.imageView.frame;
        movieView.clipsToBounds = YES;
        [self.view addSubview:movieView];
        self.imageView.hidden = YES;
    }
}
-(void)pickMediaFromSource:(UIImagePickerControllerSourceType)sourceType{

    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    
    if ([UIImagePickerController isSourceTypeAvailable:sourceType] && [mediaTypes count]>0) {
        
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.mediaTypes = mediaTypes;
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:NULL];
    }else{
    
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error accessing media" message:@"Unsupported media source." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Drat!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:NULL];
    }

}
-(UIImage *)shrinkImage:(UIImage *)original toSize:(CGSize)size{  //对图像进行缩小以适应显示它的图像视图，为减小使用的uiimage的内存以及imageView为了显示图像的内存量，以原始图像比率绘制

    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    
    CGFloat originalAspect = original.size.width / original.size.height;
    CGFloat targetAspect = size.width / size.height;
    CGRect targetRect;
    
    
    if (originalAspect > targetAspect) {
        
        targetRect.size.width = size.width;
        targetRect.size.height = size.height * targetAspect / originalAspect;
        targetRect.origin.x = 0;
        targetRect.origin.y = (size.height - targetRect.size.height) *0.5;
    }else if (originalAspect < targetAspect){
    
        targetRect.size.width = size.width *originalAspect/targetAspect;
        targetRect.size.height = size.height;
        targetRect.origin.x = (size.width - targetRect.size.width) *0.5;
        targetRect.origin.y = 0;
    }else{
    
        targetRect = CGRectMake(0, 0, size.width, size.height);
    }
    
    [original drawInRect:targetRect];
    UIImage *final = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return final;
}
#pragma mark 触发事件
-(IBAction)shootPictureOrVideo:(id)sender{

    [self pickMediaFromSource:UIImagePickerControllerSourceTypeCamera];  //选取拍照摄像头呀
}
-(IBAction)selectExistingPictureOrVideo:(id)sender{
[self pickMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];  //图库
}

#pragma mark Image picker Controler delagate methods 判断用户选中照片还是视频
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
  
    self.lastChosenMediaType = info[UIImagePickerControllerMediaType];
    
    if ([self.lastChosenMediaType isEqual:(NSString *)kUTTypeImage]) {
        
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        self.image = [self shrinkImage:chosenImage toSize:self.imageView.bounds.size];
        
    }else if ([self.lastChosenMediaType isEqual:(NSString *)kUTTypeMovie]){
        self.movieURL = info[UIImagePickerControllerMediaURL];
    
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];

}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{


    [picker dismissViewControllerAnimated:YES completion:NULL];
}
@end
