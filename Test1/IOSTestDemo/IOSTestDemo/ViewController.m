//
//  ViewController.m
//  IOSTestDemo
//
//  Created by wangfubin on 17/3/24.
//  Copyright © 2017年 wangfubin. All rights reserved.
//

//通过修改stroyboard的viewcontroller类进行更换demo
#import "ViewController.h"

@interface ViewController ()
@property (nonatomic , strong) EAGLContext* mContext;
@property (nonatomic , strong) GLKBaseEffect* mEffect;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupConfig];
    [self uploadVertexArray];
    [self uploadTexture];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupConfig
{
    //新建OpenGLES上下文
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    GLKView *view = (GLKView *)self.view; //在storyboard里边要添加
    //如果在storyboard里边没有设置，可以设置代理
    //view.delegate = self;
    
    view.context = self.mContext;
    //颜色缓冲区格式
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    [EAGLContext setCurrentContext:self.mContext];
}

- (void)uploadVertexArray
{
    //顶点数据，前三个是顶点坐标，后面两个是纹理坐标,
    //纹理坐标的取值是［0，1］，原点在左下角，
    //opengles的世界坐标取值是［－1，1］，原点在屏幕中间
    
    //这里是2个三角形6个点构成一个矩形，用4个点也可以
    GLfloat squareVertexData[] =
    {
        //测试1
//        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
//        0.5, 0.5, -0.0f,    1.0f, 1.0f, //右上
//        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
//        
//        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
//        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
//        -0.5, -0.5, 0.0f,   0.0f, 0.0f, //左下
        
        //测试2
        0.0, -0.5, 0.0f,    1.0f, 0.0f, //右下
        0.0, 0.5, -0.0f,    1.0f, 1.0f, //右上
        -1.0, 0.5, 0.0f,    0.0f, 1.0f, //左上
        
        0.0, -0.5, 0.0f,    1.0f, 0.0f, //右下
        -1.0, 0.5, 0.0f,    0.0f, 1.0f, //左上
        -1.0, -0.5, 0.0f,   0.0f, 0.0f, //左下
        
        //第二个矩形里边的2个三角形
        1.0, -0.5, 0.0f,    1.0f, 0.0f, //右下
        1.0, 0.5, -0.0f,    1.0f, 1.0f, //右上
        0.0, 0.5, 0.0f,    0.0f, 1.0f, //左上
        
        1.0, -0.5, 0.0f,    1.0f, 0.0f, //右下
        0.0, 0.5, 0.0f,    0.0f, 1.0f, //左上
        0.0, -0.5, 0.0f,   0.0f, 0.0f, //左下
    };
    
    //顶点数据缓存，vbo的使用
    GLuint buffer;
    glGenBuffers(1, &buffer); //生成buffer
    glBindBuffer(GL_ARRAY_BUFFER, buffer);  //绑定标识符到GL_ARRAY_BUFFER
    //把顶点数据从cpu内存复制到gpu内存
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);  //开启对应的顶点属性，顶点数据缓存
    //顶点数组可以通过glBufferData放入缓存，也可以直接通过glVertexAttribPointer最后一个参数，直接把顶点数组从CPU传送到GPU。区别：glBufferData里面的顶点缓存可以复用，glVertexAttribPointer是每次都会把顶点数组从CPU发送到GPU，影响性能。
    
    //设置合适的格式从buffer里读取数据
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0); //纹理
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
}

- (void)uploadTexture
{
    //纹理贴图
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"timg" ofType:@"png"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil]; //GLKTextureLoaderOriginBottomLeft纹理坐标系是相反的，原点在左下
    //GLKTextureLoader读取图片创建纹理GLKTextureInfo
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    //着色器shader
    self.mEffect = [[GLKBaseEffect alloc] init];
    self.mEffect.texture2d0.enabled = GL_TRUE;
    self.mEffect.texture2d0.name = textureInfo.name;
}

/**
 *  渲染场景代码
 */
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.3f, 0.6f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //启动着色器
    [self.mEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 12); //这个是画顶点0-6是第一个矩形，0-12是2个矩形都画出来
}
@end
