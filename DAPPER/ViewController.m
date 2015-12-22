//
//  ViewController.m
//  DAPPER
//
//  Created by xu jason on 14-3-22.
//  Copyright (c) 2014年 Vbenz. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeGenerator.h"

#import "ImageViewController.h"

#define MAX_CHARACTERISTIC_VALUE_SIZE 20

@interface ViewController ()<UITextViewDelegate>{
    UartLib *uartLib;
    
    CBPeripheral	*connectPeripheral;
    
    UIAlertView *connectAlertView;
    
    NSMutableArray      *sendDataArray;
}

@end

@implementation ViewController
@synthesize peripheralName;
@synthesize sendDataView;
@synthesize recvDataView;
@synthesize sendButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"dierci");
    
    NSLog(@"第三次");
    
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    connectPeripheral = nil;
    
    uartLib = [[UartLib alloc] init];
    
    [uartLib setUartDelegate:self];
    
    [[self sendButton] setEnabled:FALSE];
    
    connectAlertView = [[UIAlertView alloc] initWithTitle:@"Connect bluetooth peripheral" message: @"Connecting...,Please wait!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil,nil];
        // Do any additional setup after loading the view, typically from a nib.
    
    sendDataArray = [[NSMutableArray alloc] init];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)0.02 target:self selector:@selector(sendDataTimer:) userInfo:nil repeats:YES];
}

- (void) sendDataTimer:(NSTimer *)timer {
        //NSLog(@"send data timer");
    
    if ([sendDataArray count] > 0) {
        NSData* cmdData;
        
        cmdData = [sendDataArray objectAtIndex:0];
        
        [uartLib sendValue:connectPeripheral sendData:cmdData type:CBCharacteristicWriteWithResponse];
        
        [sendDataArray removeObjectAtIndex:0];
    }
    
    
    /*
     NSInteger nCount;
     
     nCount = [sendDataArray count];
     if (nCount == 0) {
     return;
     }
     
     if (nCount > 3) {
     nCount = 3;
     }
     for (int i = 0; i<nCount; i++) {
     NSData* cmdData;
     
     cmdData = [sendDataArray objectAtIndex:0];
     
     [uartLib sendValue:connectPeripheral sendData:cmdData type:CBCharacteristicWriteWithoutResponse];
     
     [sendDataArray removeObjectAtIndex:0];
     }
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

Byte calculateXor(Byte *pcData, Byte ucDataLen){
    Byte ucXor = 0;
    Byte i;
    
    for (i=0; i<ucDataLen; i++) {
        ucXor ^= *(pcData+i);
    }
    
    return ucXor;
}


- (IBAction)scanStart:(id)sender{
    [uartLib scanStart];
}

- (IBAction)scanStop:(id)sender{
    [uartLib scanStop];
}

- (IBAction)connect:(id)sender{
    NSLog(@"connect Peripheral");
    [uartLib scanStop];
    [uartLib connectPeripheral:connectPeripheral];
    
    [connectAlertView show];
}

- (IBAction)Disconnect:(id)sender{
    [uartLib scanStop];
    [uartLib disconnectPeripheral:connectPeripheral];
}

- (IBAction)sendData:(id)sender{
    /*
     Byte byte[] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29};
     NSData *sendData;
     
     sendData = [[NSData alloc] initWithBytes:byte length:30];
     [uartLib sendValue:connectPeripheral sendData:sendData type:CBCharacteristicWriteWithResponse];
     */
    
    /*
     NSData *sendData = [[sendDataView text] dataUsingEncoding: NSASCIIStringEncoding];
     
     [uartLib sendValue:connectPeripheral sendData:sendData type:CBCharacteristicWriteWithResponse];
     */
    
    Byte ucaCmdData[10];
    
    
    memset(ucaCmdData, 0, 10);
    ucaCmdData[0] = 0xfe;
    ucaCmdData[1] = 0x04;
    ucaCmdData[2] = 0x02;
    ucaCmdData[3] = calculateXor(ucaCmdData, 3);
    
    NSData *cmdData =[[NSData alloc] initWithBytes:ucaCmdData length:4];
    NSLog(@"get temperature:%@", cmdData);
    
    [uartLib sendValue:connectPeripheral sendData:cmdData type:CBCharacteristicWriteWithResponse];
}

- (IBAction)printInput:(id)sender{
    NSString *curPrintContent;
    
    curPrintContent = [sendDataView text];
    
    if ([curPrintContent length]) {
        NSString *printed = [curPrintContent stringByAppendingFormat:@"%c%c%c", '\n', '\n', '\n'];
        
        [self PrintWithFormat:printed];
        [self.sendDataView resignFirstResponder];
    }
}

- (IBAction)printQR:(id)sender{
    Byte caPrintCmd[50];
    
//    NSString * str = sendDataView.text;
//    
//    NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
//    Byte * testByte = (Byte*)[data bytes];
//    
//    int a = [str intValue];
//    Byte endbyte = (Byte)0xff&a;
    
    
        //设置二维码到宽度
    caPrintCmd[0] = 0x1d;
    caPrintCmd[1] = 0x77;
    caPrintCmd[2] = 5;
    NSData *cmdData =[[NSData alloc] initWithBytes:caPrintCmd length:3];
    NSLog(@"QR width:%@", cmdData);
    
    [uartLib sendValue:connectPeripheral sendData:cmdData type:CBCharacteristicWriteWithResponse];
    
    caPrintCmd[0] = 0x1d;
    caPrintCmd[1] = 0x6b;
    caPrintCmd[2] = 97;
    caPrintCmd[3] = 0x00;
    caPrintCmd[4] = 0x02;
    caPrintCmd[5] = 0x05;
    caPrintCmd[6] = 0x00;
    caPrintCmd[7] = 0x31;
    caPrintCmd[8] = 0x32;
    caPrintCmd[9] = 0x33;
    caPrintCmd[10] = 0x34;
    caPrintCmd[11] = 0x35;
    
    caPrintCmd[12] = '\n';
    caPrintCmd[13] = '\n';
    caPrintCmd[14] = '\n';
    cmdData =[[NSData alloc] initWithBytes:caPrintCmd length:15];
    NSLog(@"QR data:%@", cmdData);
    
    [uartLib sendValue:connectPeripheral sendData:cmdData type:CBCharacteristicWriteWithResponse];
}

- (IBAction)printQR_1:(id)sender{
    Byte caPrintCmd[50];
    
        //设置二维码到宽度
    caPrintCmd[0] = 0x1a;
    caPrintCmd[1] = 0x5b;
    caPrintCmd[2] = 0x01;
    caPrintCmd[3] = 0x00;
    caPrintCmd[4] = 0x00;
    caPrintCmd[5] = 0x00;
    caPrintCmd[6] = 0x00;
    caPrintCmd[7] = 0x80;
    caPrintCmd[8] = 0x01;
    caPrintCmd[9] = 0x00;
    caPrintCmd[10] = 0x03;
    caPrintCmd[11] = 0x00;
    NSData *cmdData =[[NSData alloc] initWithBytes:caPrintCmd length:12];
    NSLog(@"QR width:%@", cmdData);
    
    [uartLib sendValue:connectPeripheral sendData:cmdData type:CBCharacteristicWriteWithResponse];
    
    caPrintCmd[0] = 0x1a;
    caPrintCmd[1] = 0x31;
    caPrintCmd[2] = 0x00;
    caPrintCmd[3] = 0x08;
    caPrintCmd[4] = 0x04;
    caPrintCmd[5] = 0x00;
    caPrintCmd[6] = 0x00;
    caPrintCmd[7] = 0x00;
    caPrintCmd[8] = 0x00;
    caPrintCmd[9] = 0x04;
    caPrintCmd[10] = 0x00;
    caPrintCmd[11] = 0x30;
    caPrintCmd[12] = 0x31;
    caPrintCmd[13] = 0x32;
    caPrintCmd[14] = 0x00;
    cmdData =[[NSData alloc] initWithBytes:caPrintCmd length:15];
    NSLog(@"QR data:%@", cmdData);
    
    [uartLib sendValue:connectPeripheral sendData:cmdData type:CBCharacteristicWriteWithResponse];

	  caPrintCmd[0] = 0x1a;
    caPrintCmd[1] = 0x5d;
    caPrintCmd[2] = 0x00;
    caPrintCmd[3] = 0x1a;
    caPrintCmd[4] = 0x4f;
    caPrintCmd[5] = 0x00;
    cmdData =[[NSData alloc] initWithBytes:caPrintCmd length:6];
    NSLog(@"QR data:%@", cmdData);
    
    [uartLib sendValue:connectPeripheral sendData:cmdData type:CBCharacteristicWriteWithResponse];
}


- (IBAction)printQR_2:(id)sender{
    [self printTwoDimenCode:@"12345678"];
}

- (void) printTwoDimenCode:(NSString *)printContent{
    NSData *printFormat;
    Byte caPrintFmt[500];
    
    caPrintFmt[0] = 0x1b;
    caPrintFmt[1] = 0x40;
    
    caPrintFmt[2] = 0x1d;
    caPrintFmt[3] = 0x28;
    
    caPrintFmt[4] = 0x6b;
    
    caPrintFmt[5] = 0x03;
    caPrintFmt[6] = 0x00;
    caPrintFmt[7] = 0x31;
    caPrintFmt[8] = 0x43;
    caPrintFmt[9] = 0x08;
    
    
    caPrintFmt[10] = 0x1d;
    caPrintFmt[11] = 0x28;
    
    caPrintFmt[12] = 0x6b;
    
    caPrintFmt[13] = 0x03;
    caPrintFmt[14] = 0x00;
    caPrintFmt[15] = 0x31;
    caPrintFmt[16] = 0x45;
    caPrintFmt[17] = 0x30;
    
        //caPrintFmt[] = ;
        //caPrintFmt[] = ;
    printFormat = [NSData dataWithBytes:caPrintFmt length:18];
    NSLog(@"format:%@", printFormat);
    
    [sendDataArray addObject:printFormat];
    
    
    
    NSInteger nLength = [printContent length];
    nLength += 3;
    
    caPrintFmt[0] = 0x1d;
    caPrintFmt[1] = 0x28;
    
    caPrintFmt[2] = 0x6b;
    
    caPrintFmt[3] = nLength & 0xFF;
    caPrintFmt[4] = (nLength >> 8) & 0xFF;
    caPrintFmt[5] = 0x31;
    caPrintFmt[6] = 0x50;
    caPrintFmt[7] = 0x30;
    
    
    NSData *printData = [printContent dataUsingEncoding: NSASCIIStringEncoding];
    Byte *printByte = (Byte *)[printData bytes];
    
    nLength -= 3;
    for (int  i = 0; i<nLength; i++) {
        caPrintFmt[8+i] = *(printByte+i);
    }
    
    printFormat = [NSData dataWithBytes:caPrintFmt length:nLength+8];
    
    NSLog(@"format:%@", printFormat);
    
    [self printLongData:printFormat];
        //[sendDataArray addObject:printFormat];
    
    
    
    caPrintFmt[0] = 0x1b;
    caPrintFmt[1] = 0x61;
    
    caPrintFmt[2] = 0x01;
    
    
    
    caPrintFmt[3] = 0x1d;
    caPrintFmt[4] = 0x28;
    
    caPrintFmt[5] = 0x6b;
    
    caPrintFmt[6] = 0x03;
    caPrintFmt[7] = 0x00;
    caPrintFmt[8] = 0x31;
    caPrintFmt[9] = 0x52;
    caPrintFmt[10] = 0x30;
    
    
    caPrintFmt[11] = 0x1d;
    caPrintFmt[12] = 0x28;
    
    caPrintFmt[13] = 0x6b;
    
    caPrintFmt[14] = 0x03;
    caPrintFmt[15] = 0x00;
    caPrintFmt[16] = 0x31;
    caPrintFmt[17] = 0x51;
    caPrintFmt[18] = 0x30;
    
        //caPrintFmt[] = ;
        //caPrintFmt[] = ;
    printFormat = [NSData dataWithBytes:caPrintFmt length:19];
    NSLog(@"format:%@", printFormat);
    
    [sendDataArray addObject:printFormat];
    
    
    caPrintFmt[0] = 0x1b;
    caPrintFmt[1] = 0x40;
    
        //caPrintFmt[] = ;
        //caPrintFmt[] = ;
    printFormat = [NSData dataWithBytes:caPrintFmt length:2];
    NSLog(@"format:%@", printFormat);
    
    [sendDataArray addObject:printFormat];
}

- (void) printLongData:(NSData *)printContent{
    NSUInteger i;
    NSUInteger strLength;
    NSUInteger cellCount;
    NSUInteger cellMin;
    NSUInteger cellLen;
    
    strLength = [printContent length];
    if (strLength < 1) {
        return;
    }
    
    cellCount = (strLength%MAX_CHARACTERISTIC_VALUE_SIZE)?(strLength/MAX_CHARACTERISTIC_VALUE_SIZE + 1):(strLength/MAX_CHARACTERISTIC_VALUE_SIZE);
    for (i=0; i<cellCount; i++) {
        cellMin = i*MAX_CHARACTERISTIC_VALUE_SIZE;
        if (cellMin + MAX_CHARACTERISTIC_VALUE_SIZE > strLength) {
            cellLen = strLength-cellMin;
        }
        else {
            cellLen = MAX_CHARACTERISTIC_VALUE_SIZE;
        }
        
        NSLog(@"print:%lu,%lu,%lu,%lu", (unsigned long)strLength,(unsigned long)cellCount, (unsigned long)cellMin, (unsigned long)cellLen);
        NSRange rang = NSMakeRange(cellMin, cellLen);
        NSData *subData = [printContent subdataWithRange:rang];
        
        NSLog(@"print:%@", subData);
            //data = [strRang dataUsingEncoding: NSUTF8StringEncoding];
            //NSLog(@"print:%@", data);
        
        [sendDataArray addObject:subData];
    }
}

- (IBAction)printBarCode:(id)sender{
    Byte caPrintCmd[50];
    
        //设置绝对打印位置
    caPrintCmd[0] = 0x1b;
    caPrintCmd[1] = 0x24;
    caPrintCmd[2] = 10;
    caPrintCmd[3] = 0x00;
    
        //设置条码宽度
    caPrintCmd[4] = 0x1d;
    caPrintCmd[5] = 0x77;
    caPrintCmd[6] = 0x5; //2<=n<=6
    
        //设置条码高度
    caPrintCmd[7] = 0x1d;
    caPrintCmd[8] = 0x68;
    caPrintCmd[9] = 0xa2;//1<=n<=255
    
        //选择HRI字符字形
    caPrintCmd[10] = 0x1d;
    caPrintCmd[11] = 0x66;
    caPrintCmd[12] = 0x00;
    
        //选择HRI字符的打印位置
    caPrintCmd[13] = 0x1d;
    caPrintCmd[14] = 0x48;
    caPrintCmd[15] = 0x00;
    
        //打印条形码
    caPrintCmd[16] = 0x1d;
    caPrintCmd[17] = 0x6b;
    caPrintCmd[18] = 0x41;
    caPrintCmd[19] = 0x0c;
    caPrintCmd[20] = 0x30;
    caPrintCmd[21] = 0x31;
    caPrintCmd[22] = 0x32;
    caPrintCmd[23] = 0x33;
    caPrintCmd[24] = 0x34;
    caPrintCmd[25] = 0x35;
    caPrintCmd[26] = 0x36;
    caPrintCmd[27] = 0x37;
    caPrintCmd[28] = 0x38;
    caPrintCmd[29] = 0x39;
    caPrintCmd[30] = 0x30;
    caPrintCmd[31] = 0x31;
    caPrintCmd[32] = '\n';
    caPrintCmd[33] = '\n';
    caPrintCmd[34] = '\n';
    NSData *cmdData =[[NSData alloc] initWithBytes:caPrintCmd length:35];
    NSLog(@"Bar code:%@", cmdData);
    
    [uartLib sendValue:connectPeripheral sendData:cmdData type:CBCharacteristicWriteWithResponse];
}

- (IBAction)printPng:(id)sender{
    UIImage *printPng = [UIImage imageNamed:@"stamp.png"];
#warning 再转回来才能正常打印,不知为什么
    // libqrencode类库生成二维码(需要转成nsdata)
    UIImage * image = [QRCodeGenerator qrImageForString:@"sdfvdhjbglkjdsfbgldfbljr" imageSize:200];
  
    
    NSData * inageData = UIImageJPEGRepresentation(image, 1.0);
    UIImage * image1 = [UIImage imageWithData:inageData];
    
    
    // iOS7以上 CIFilter 生成二维码
    UIImage * printimage = [self createQRForString:@"1234都市56789"];
    
    
    
//        ImageViewController * imageVC = [[ImageViewController alloc]init];
//        imageVC.image = qrimage;
//    
//        [self presentViewController:imageVC animated:YES completion:nil];
    
    [self png2GrayscaleImage:printimage];
}

- (UIImage *) png2GrayscaleImage:(UIImage *) oriImage {
        //const int ALPHA = 0;
    const int RED = 1;
    const int GREEN = 2;
    const int BLUE = 3;
    
    int width = oriImage.size.width ;//imageRect.size.width;
    int height =oriImage.size.height;
    int imgSize = width * height;
    int x_origin = 0;
    int y_to = height;
    
        // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(imgSize * sizeof(uint32_t));
    
        // clear the pixels so any transparency is preserved
    memset(pixels, 0, imgSize * sizeof(uint32_t));
    
    NSInteger nWidthByteSize = (width+7)/8;
    
    NSInteger nBinaryImgDataSize = nWidthByteSize * y_to;
    Byte *binaryImgData = (Byte *)malloc(nBinaryImgDataSize);
    
    memset(binaryImgData, 0, nBinaryImgDataSize);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
        // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
        // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width , height), [oriImage CGImage]);
    
    
    Byte controlData[8];
    controlData[0] = 0x1d;
    controlData[1] = 0x76;//'v';
    controlData[2] = 0x30;
    controlData[3] = 0;
    controlData[4] = nWidthByteSize & 0xff;
    controlData[5] = (nWidthByteSize>>8) & 0xff;
    controlData[6] = y_to & 0xff;
    controlData[7] = (y_to>>8) & 0xff;
    NSData *printData = [[NSData alloc] initWithBytes:controlData length:8];
    [self printData:printData];
    
    for(int y = 0; y < y_to; y++) {
        for(int x = x_origin; x < width ; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
                // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
            
                // set the pixels to gray
            /*
             rgbaPixel[RED] = gray;
             rgbaPixel[GREEN] = gray;
             rgbaPixel[BLUE] = gray;
             */
            if (gray > 228) {
                rgbaPixel[RED] = 255;
                rgbaPixel[GREEN] = 255;
                rgbaPixel[BLUE] = 255;
                
            }else{
                rgbaPixel[RED] = 0;
                rgbaPixel[GREEN] = 0;
                rgbaPixel[BLUE] = 0;
                binaryImgData[(y*width+x)/8] |= (0x80>>(x%8));
            }
        }
        
        
    }
    
    printData = [[NSData alloc] initWithBytes:binaryImgData length:nBinaryImgDataSize];
    [self printData:printData];
    
    memset(controlData, '\n', 8);
    printData = [[NSData alloc] initWithBytes:controlData length:3];
    [self printData:printData];
    
    
    return 0;
}


- (void) printData:(NSData *)dataPrinted {
    NSLog(@"print data:%lu", (unsigned long)[dataPrinted length]);
//    [uartLib sendValue:connectPeripheral sendData:dataPrinted type:CBCharacteristicWriteWithoutResponse];

#define MAX_CHARACTERISTIC_VALUE_SIZE 20
    NSData  *data	= nil;
    NSUInteger i;
    NSUInteger strLength;
    NSUInteger cellCount;
    NSUInteger cellMin;
    NSUInteger cellLen;
    
    NSLog(@"print data:%@", dataPrinted);
    
    
    strLength = [dataPrinted length];
    cellCount = (strLength%MAX_CHARACTERISTIC_VALUE_SIZE)?(strLength/MAX_CHARACTERISTIC_VALUE_SIZE + 1):(strLength/MAX_CHARACTERISTIC_VALUE_SIZE);
    
    for (i=0; i<cellCount; i++) {
        cellMin = i*MAX_CHARACTERISTIC_VALUE_SIZE;
        if (cellMin + MAX_CHARACTERISTIC_VALUE_SIZE > strLength) {
            cellLen = strLength-cellMin;
        }
        else {
            cellLen = MAX_CHARACTERISTIC_VALUE_SIZE;
        }
        
        NSLog(@"print:%lu,%lu,%lu,%lu", (unsigned long)strLength,(unsigned long)cellCount, (unsigned long)cellMin, (unsigned long)cellLen);
        NSRange rang = NSMakeRange(cellMin, cellLen);
        
        data = [dataPrinted subdataWithRange:rang];
        NSLog(@"print:%@", data);
        
        [uartLib sendValue:connectPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    }
}


- (void) PrintWithFormat:(NSString *)printContent{
#define MAX_CHARACTERISTIC_VALUE_SIZE 20
    NSData  *data	= nil;
    NSUInteger i;
    NSUInteger strLength;
    NSUInteger cellCount;
    NSUInteger cellMin;
    NSUInteger cellLen;
    
    Byte caPrintFmt[5];
    
    /*初始化命令：ESC @ 即0x1b,0x40*/
    caPrintFmt[0] = 0x1b;
    caPrintFmt[1] = 0x40;
    
    /*字符设置命令：ESC ! n即0x1b,0x21,n*/
    caPrintFmt[2] = 0x1b;
    caPrintFmt[3] = 0x21;
    
    caPrintFmt[4] = 0x00;
    
    NSData *cmdData =[[NSData alloc] initWithBytes:caPrintFmt length:5];
    
    [uartLib sendValue:connectPeripheral sendData:cmdData type:CBCharacteristicWriteWithResponse];
    NSLog(@"format:%@", cmdData);
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        //NSData *data = [curPrintContent dataUsingEncoding:enc];
        //NSLog(@"dd:%@", data);
        //NSString *retStr = [[NSString alloc] initWithData:data encoding:enc];
        //NSLog(@"str:%@", retStr);
    
    strLength = [printContent length];
    if (strLength < 1) {
        return;
    }
    
    cellCount = (strLength%MAX_CHARACTERISTIC_VALUE_SIZE)?(strLength/MAX_CHARACTERISTIC_VALUE_SIZE + 1):(strLength/MAX_CHARACTERISTIC_VALUE_SIZE);
    for (i=0; i<cellCount; i++) {
        cellMin = i*MAX_CHARACTERISTIC_VALUE_SIZE;
        if (cellMin + MAX_CHARACTERISTIC_VALUE_SIZE > strLength) {
            cellLen = strLength-cellMin;
        }
        else {
            cellLen = MAX_CHARACTERISTIC_VALUE_SIZE;
        }
        
            //NSLog(@"print:%d,%d,%d,%d", strLength,cellCount, cellMin, cellLen);
        NSRange rang = NSMakeRange(cellMin, cellLen);
        NSString *strRang = [printContent substringWithRange:rang];
        NSLog(@"print:%@", strRang);
        
        data = [strRang dataUsingEncoding: enc];
            //data = [strRang dataUsingEncoding: NSUTF8StringEncoding];
        NSLog(@"print:%@", data);
            //data = [strRang dataUsingEncoding: NSUTF8StringEncoding];
            //NSLog(@"print:%@", data);
        
        [uartLib sendValue:connectPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    }
}

#pragma mark -
#pragma mark UartDelegate
/****************************************************************************/
/*                       UartDelegate Methods                        */
/****************************************************************************/
- (void) didScanedPeripherals:(NSMutableArray  *)foundPeripherals;
{
    NSLog(@"didScanedPeripherals(%lu)", (unsigned long)[foundPeripherals count]);
    
    CBPeripheral	*peripheral;
    
    for (peripheral in foundPeripherals) {
		NSLog(@"--Peripheral:%@", [peripheral name]);
	}
    
    if ([foundPeripherals count] > 0) {
        connectPeripheral = [foundPeripherals objectAtIndex:0];
        if ([connectPeripheral name] == nil) {
            [[self peripheralName] setText:@"BTCOM"];
        }else{
            [[self peripheralName] setText:[connectPeripheral name]];
        }
    }else{
        [[self peripheralName] setText:nil];
        connectPeripheral = nil;
    }
}

- (void) didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"did Connect Peripheral");
    
    [[self sendButton] setEnabled:TRUE];
    
    [connectAlertView dismissWithClickedButtonIndex:0 animated:YES];
}

- (void) didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"did Disconnect Peripheral");
    
    [[self sendButton] setEnabled:FALSE];
    [[self peripheralName] setText:@""];
    [connectAlertView dismissWithClickedButtonIndex:0 animated:YES];
    
    [[[UIAlertView alloc] initWithTitle:@"Connect fail" message: @"Fail to connect,Please reconnect!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil,nil] show];
}

- (void) didWriteData:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"didWriteData:%@", [peripheral name]);
}

- (void) didReceiveData:(CBPeripheral *)peripheral recvData:(NSData *)recvData
{
    NSLog(@"uart recv(%lu):%@", (unsigned long)[recvData length], recvData);
    [self promptDisplay:recvData];
}

- (void) didBluetoothPoweredOff{
    
}
- (void) didBluetoothPoweredOn{
    
}

- (void) didRetrievePeripheral:(NSArray *)peripherals{
    
}

- (void) didRecvRSSI:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI{
    
}
- (void) didDiscoverPeripheral:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI{
    
}

- (void) didDiscoverPeripheralAndName:(CBPeripheral *)peripheral DevName:(NSString *)devName{
    
}

- (void) didrecvCustom:(CBPeripheral *)peripheral CustomerRight:(bool) bRight{
    
}

#pragma mark -
#pragma mark tools function
- (void) promptDisplay:(NSData *)recvData{
    NSString *prompt;
    
    NSString *hexStr=@"";
    
    hexStr = [[NSString alloc] initWithData:recvData encoding:NSASCIIStringEncoding];
    /*
     Byte *hexData = (Byte *)[recvData bytes];
     
     for(int i=0; i<[recvData length];i++)
     {
     NSString *newHexStr = [NSString stringWithFormat:@"%x",hexData[i]&0xff];///16进制数
     if([newHexStr length]==1)
     hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
     else
     hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
     }
     */
    if ([[[self recvDataView] text] length] > 0) {
        if (hexStr) {
            prompt = [[NSString alloc]initWithFormat:@"R:%@\r\n%@", hexStr, [[self recvDataView] text]];
        }
    }else {
        if (hexStr) {
            prompt = [[NSString alloc]initWithFormat:@"R:%@\r\n", hexStr];
        }
    }
    
    [[self recvDataView] setText:prompt];
}

#pragma mark -
#pragma mark UITextViewDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField

{
    [textField resignFirstResponder];
    
    return YES;
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView == connectAlertView) {
        switch (buttonIndex) {
            case 0:
                NSLog(@"Cancel Button Pressed");
                [uartLib scanStop];
                [uartLib disconnectPeripheral:connectPeripheral];
                break;
                
            default:
                break;
        }
    }
    
}


- (UIImage *)createQRForString:(NSString *)qrString {
  
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    [filter setDefaults];
    
    NSData *data = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    [filter setValue:data
              forKey:@"inputMessage"];
    
    CIImage *outputImage = [filter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:[outputImage extent]];
    
    UIImage *image = [UIImage imageWithCGImage:cgImage
                                         scale:0.1
                                   orientation:UIImageOrientationUp];
    
    // 不失真的放大
    UIImage *resized = [self resizeImage:image
                             withQuality:kCGInterpolationNone
                                    rate:5.0];
    
    // 缩放到固定的宽度(高度与宽度一致)
    UIImage * endImage = [self scaleWithFixedWidth:200 image:resized];
    
    CGImageRelease(cgImage);
    
    return endImage;
    
}

- (UIImage *)scaleWithFixedWidth:(CGFloat)width image:(UIImage *)image
{
    float newHeight = image.size.height * (width / image.size.width);
    CGSize size = CGSizeMake(width, newHeight);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
    
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageOut;
}

- (UIImage *)resizeImage:(UIImage *)image
             withQuality:(CGInterpolationQuality)quality
                    rate:(CGFloat)rate
{
    UIImage *resized = nil;
    CGFloat width = image.size.width * rate;
    CGFloat height = image.size.height * rate;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, quality);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resized;
}

//生成二维码------暂时不可以
- (CIImage *)creatQRForString:(NSString *)qrString {
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // 创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 设置内容和纠错级别
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    // 返回CIImage
    return qrFilter.outputImage;
}

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}
- (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900)    // 将白色变成透明
        {
            // 改成下面的代码，会将图片转成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }
        else
        {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

@end
