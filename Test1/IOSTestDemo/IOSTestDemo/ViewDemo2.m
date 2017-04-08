//
//  ViewDemo2.m
//  IOSTestDemo
//
//  Created by 王福滨 on 17/3/25.
//  Copyright © 2017年 wangfubin. All rights reserved.
//

#import "ViewDemo2.h"
#import <OpenGLES/ES3/gl.h>

@interface ViewDemo2()

@property(nonatomic, strong) EAGLContext *myContext;
@property(nonatomic, strong) CAEAGLLayer *myEagLayer;
@property(nonatomic, assign) GLuint myProgram;

@property(nonatomic, assign) GLuint myColorRenderBuffer;
@property(nonatomic, assign) GLuint myColorFrameBuffer;

- (void)setupLayer;

@end

@implementation ViewDemo2

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)layoutSubviews {
    
    [self setupLayer];
    
    [self setupContext];
    
    [self destoryRenderAndFrameBuffer];
    
    [self setupRenderBuffer];
    
    [self setupFrameBuffer];
    
    [self render];
}

- (void)setupLayer
{
    self.myEagLayer = (CAEAGLLayer *)self.layer;
    //设置放大倍数
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    self.myEagLayer.opaque = YES;
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    self.myEagLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],
                                          kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext
{
    // 指定 OpenGL 渲染 API 的版本
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES3;
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:api];
    if(!context)
    {
        NSLog(@"Failed to initialize OpenGLES 3.0 context");
        exit(1);
    }
    
    //设置为当前上下文
    if(![EAGLContext setCurrentContext:context])
    {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
    self.myContext = context;
}

- (void)setupRenderBuffer
{
    GLuint buffer;
    glGenRenderbuffers(1, &buffer);
    self.myColorRenderBuffer = buffer;
    glBindRenderbuffer(GL_RENDERBUFFER, self.myColorRenderBuffer);
    // 为 颜色缓冲区 分配存储空间
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEagLayer];
}

- (void)setupFrameBuffer
{
    GLuint buffer;
    glGenFramebuffers(1, &buffer);
    self.myColorFrameBuffer = buffer;
    //设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, self.myColorFrameBuffer);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myColorRenderBuffer);
}

- (void)destoryRenderAndFrameBuffer
{
    glDeleteFramebuffers(1, &_myColorFrameBuffer);
    self.myColorFrameBuffer = 0;
    glDeleteRenderbuffers(1, &_myColorRenderBuffer);
    self.myColorRenderBuffer = 0;
}

/**
 *  c语言编译流程：预编译、编译、汇编、链接
 *  glsl的编译过程主要有glCompileShader、glAttachShader、glLinkProgram三步；
 *  @param vert 顶点着色器
 *  @param frag 片元着色器
 *
 *  @return 编译成功的shaders
 */
- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    //读取字符串
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar* source = (GLchar *)[content UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
}

- (GLuint)loadShaders:(NSString *)vert frag:(NSString *)frag
{
    GLuint verShader, fragShader;
    GLuint program = glCreateProgram();
    
    //编译
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    //释放不需要的shader
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return program;
}

//加载纹理
- (GLuint)setupTexture:(NSString *)fileName
{
    // 1获取图片的CGImageRef
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    // 2 读取图片的大小
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    //rgba共4个byte
    GLubyte *spriteData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 3在CGContextRef上绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    //4绑定纹理到默认的纹理ID（这里只有一张图片，故而相当于默认于片元着色器里面的colorMap，如果有多张图不可以这么做）
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    glBindTexture(GL_TEXTURE_2D, 0); //2次调用
    free(spriteData);
    return 0;
}

- (void)render
{
    glClearColor(0, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    //获取视图放大倍数，可以把scale设置为1试试
    CGFloat scale = [[UIScreen mainScreen] scale];
    //设置视口大小
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);
    
    //读取文件路径
    NSString* vertFile = [[NSBundle mainBundle] pathForResource:@"shadervDemo2" ofType:@"vsh"];
    NSString* fragFile = [[NSBundle mainBundle] pathForResource:@"shaderfDemo2" ofType:@"fsh"];
    
    //加载shader
    self.myProgram = [self loadShaders:vertFile frag:fragFile];
    
    //链接
    glLinkProgram(self.myProgram);
    GLint linkSuccess;
    glGetProgramiv(self.myProgram, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) { //连接错误
        GLchar messages[256];
        glGetProgramInfoLog(self.myProgram, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"error%@", messageString);
        return ;
    }
    else
    {
        NSLog(@"link ok");
        glUseProgram(self.myProgram); //成功便使用，避免由于未使用导致的的bug
    }
    
    //前三个是顶点坐标， 后面两个是纹理坐标
    GLfloat attrArr[] =
    {
        //这里对应的纹理左边是上下颠倒的
//        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,  //右下
//        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,  //左上
//        -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,  //左下
//        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,  //右上
//        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,  //左上
//        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,  //右下
        
        //通过修改纹理坐标或者变化矩阵使得纹理不反，这是逆时针转180度，跟原图是Y轴对称
//        0.5f, -0.5f, -1.0f,     0.0f, 1.0f,  //右下－左上
//        -0.5f, 0.5f, -1.0f,     1.0f, 0.0f,  //左上－右下
//        -0.5f, -0.5f, -1.0f,    1.0f, 1.0f,  //左下－右上
//        0.5f, 0.5f, -1.0f,      0.0f, 0.0f,  //右上－左下
//        -0.5f, 0.5f, -1.0f,     1.0f, 0.0f,  //左上－右下
//        0.5f, -0.5f, -1.0f,     0.0f, 1.0f,  //右下－左上
        
        //纹理根原图上下颠倒，因此有如下对应关系
        0.5f, -0.5f, -1.0f,     1.0f, 1.0f,  //右下－右上
        -0.5f, 0.5f, -1.0f,     0.0f, 0.0f,  //左上－左下
        -0.5f, -0.5f, -1.0f,    0.0f, 1.0f,  //左下－左上
        0.5f, 0.5f, -1.0f,      1.0f, 0.0f,  //右上－右下
        -0.5f, 0.5f, -1.0f,     0.0f, 0.0f,  //左上－左下
        0.5f, -0.5f, -1.0f,     1.0f, 1.0f,  //右下－右上
    };
    
    //使用vbo,定点缓存对象
    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    //和demo1比较异同
    GLuint position = glGetAttribLocation(self.myProgram, "position");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    glEnableVertexAttribArray(position);
    
    GLuint textCoor = glGetAttribLocation(self.myProgram, "textCoordinate");
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
    glEnableVertexAttribArray(textCoor);
    
    //加载纹理
    [self setupTexture:@"timg"];
    
    //获取shader里面的变量，这里记得要在glLinkProgram后面，后面，后面！
    GLuint rotate = glGetUniformLocation(self.myProgram, "rotateMatrix");
    
    //度数转弧度
    float radians = 10 * 3.14159f / 180.0f;
    float s = sin(radians);
    float c = cos(radians);
    
    //z轴旋转矩阵
    //opengl是右手定则，所以逆时针是正方向,因此这里是逆时针转10度
    //这里的z轴旋转矩阵和上面给出来的旋转矩阵并不一致。
    //究其原因就是OpenGLES是列主序矩阵，对于一个一维数组表示的二维矩阵，会先填满每一列（a[0][0]、a[1][0]、a[2][0]、a[3][0]）。
    //把矩阵赋值给glsl对应的变量，然后就可以在glsl里面计算出旋转后的矩阵
    GLfloat zRotation[16] = { //
        c, -s, 0, 0, //
        s, c, 0, 0,//
        0, 0, 1.0, 0,//
        0.0, 0, 0, 1.0//
    };
    
    //设置旋转矩阵
    glUniformMatrix4fv(rotate, 1, GL_FALSE, (GLfloat *)&zRotation[0]);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
