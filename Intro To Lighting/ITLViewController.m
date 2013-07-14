//
//  ITLViewController.m
//  Intro To Lighting
//
//  Created by Hamdan Javeed on 2013-07-14.
//  Copyright (c) 2013 Hamdan Javeed. All rights reserved.
//

#import "ITLViewController.h"
#import "GLEU.h"

#pragma mark - preamble

typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
} vertex;

typedef struct {
    vertex vertex[3];
} triangle;

// base
static const vertex vertex0 = {{-0.5f, -0.5f, 0.0f}, {0.0f, 0.0f, 1.0f}};
static const vertex vertex1 = {{ 0.5f, -0.5f, 0.0f}, {0.0f, 0.0f, 1.0f}};
static const vertex vertex2 = {{-0.5f,  0.5f, 0.0f}, {0.0f, 0.0f, 1.0f}};
static const vertex vertex3 = {{ 0.5f,  0.5f, 0.0f}, {0.0f, 0.0f, 1.0f}};

// pyramid
static const vertex vertex4 = {{-0.25f, -0.25f, 0.0f}, {0.0f, 0.0f, 1.0f}};
static const vertex vertex5 = {{ 0.25f, -0.25f, 0.0f}, {0.0f, 0.0f, 1.0f}};
static const vertex vertex6 = {{-0.25f,  0.25f, 0.0f}, {0.0f, 0.0f, 1.0f}};
static const vertex vertex7 = {{ 0.25f,  0.25f, 0.0f}, {0.0f, 0.0f, 1.0f}};

// apex
static const vertex vertex8 = {{ 0.0f,  0.0f,  0.0f}, {0.0f, 0.0f, 1.0f}};

static triangle TriangleMake(const vertex a, const vertex b, const vertex c);

#pragma mark - interface extension

@interface ITLViewController () {
    triangle geometry[6];
}

@property (strong, nonatomic) GLEUVertexAttributeArrayBuffer *geometryVertexBuffer;
@property (strong, nonatomic) GLKBaseEffect *effect;
@end

#pragma mark - implementation

@implementation ITLViewController

- (GLEUVertexAttributeArrayBuffer *)geometryVertexBuffer {
    if (!_geometryVertexBuffer) {
        _geometryVertexBuffer = [[GLEUVertexAttributeArrayBuffer alloc] initWithStride:sizeof(vertex)
                                                                      numberOfVertices:sizeof(geometry) / sizeof(vertex)
                                                                                  data:geometry
                                                                                 usage:GL_DYNAMIC_DRAW];
    }
    return _geometryVertexBuffer;
}
- (GLKBaseEffect *)effect {
    if (!_effect) {
        _effect = [[GLKBaseEffect alloc] init];
    }
    return _effect;
}

- (void)viewDidLoad {
    GLKView *view = (GLKView *)self.view;
    
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    
    [self.effect.light0 setEnabled:GL_TRUE];
    [self.effect.light0 setDiffuseColor:GLKVector4Make(0.7f, 0.7f, 0.7f, 1.0f)];
    [self.effect.light0 setPosition:GLKVector4Make(1.0f, 0.0f, 1.0f, 0.0f)];
    
    // base
    geometry[0] = TriangleMake(vertex0, vertex1, vertex2);
    geometry[1] = TriangleMake(vertex3, vertex2, vertex1);
    
    // pyramid
    geometry[2] = TriangleMake(vertex8, vertex4, vertex5);
    geometry[3] = TriangleMake(vertex8, vertex6, vertex4);
    geometry[4] = TriangleMake(vertex8, vertex7, vertex6);
    geometry[5] = TriangleMake(vertex8, vertex5, vertex7);
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
}

- (void)glkView:(GLKView *)view
     drawInRect:(CGRect)rect {
    
    [self.effect prepareToDraw];
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.geometryVertexBuffer prepareToDrawWithAttribute:GLKVertexAttribPosition
                                         numberOfVertices:3
                                                   offset:offsetof(vertex, position)
                                    shouldEnableAttribute:YES];
    [self.geometryVertexBuffer prepareToDrawWithAttribute:GLKVertexAttribNormal
                                         numberOfVertices:3
                                                   offset:offsetof(vertex, normal)
                                    shouldEnableAttribute:YES];
    [self.geometryVertexBuffer drawVertexArrayWithMode:GL_TRIANGLES
                                      startVertexIndex:0
                                      numberOfVertices:sizeof(geometry) / sizeof(vertex)];
}

- (IBAction)vertex8ZValueDidChange:(UISlider *)sender {
    vertex newVertex8 = vertex8;
    newVertex8.position.z = sender.value;
    
    geometry[2] = TriangleMake(newVertex8, vertex4, vertex5);
    geometry[3] = TriangleMake(newVertex8, vertex6, vertex4);
    geometry[4] = TriangleMake(newVertex8, vertex7, vertex6);
    geometry[5] = TriangleMake(newVertex8, vertex5, vertex7);
    
    // the only part i dont get so far
    for (int i = 0; i < sizeof(geometry) / sizeof(triangle); i++) {
        GLKVector3 normal = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(geometry[i].vertex[1].position, geometry[i].vertex[0].position), GLKVector3Subtract(geometry[i].vertex[2].position, geometry[i].vertex[0].position)));
        geometry[i].vertex[0].normal = normal;
        geometry[i].vertex[1].normal = normal;
        geometry[i].vertex[2].normal = normal;
    }
    
    [self.geometryVertexBuffer reInitWithStride:sizeof(vertex)
                               numberOfVertices:sizeof(geometry) / sizeof(vertex)
                                           data:geometry];
}

@end

#pragma mark - triangle functions

static triangle TriangleMake(const vertex a, const vertex b, const vertex c) {
    triangle result;
    result.vertex[0] = a;
    result.vertex[1] = b;
    result.vertex[2] = c;
    return result;
}
