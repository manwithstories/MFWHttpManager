MFWHttpManager <a href="#介绍">简介</a>
==============
[![Support](https://img.shields.io/badge/support-iOS%207%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/)&nbsp;
[![Support](https://img.shields.io/badge/support-AFNetWorking-blue.svg)](https://github.com/AFNetworking/AFNetworking)&nbsp;


Introduction
==============

一个基于AFNetworking的高度封装的Http请求管理库。


Features
==============
- **结构**:分为三个部分。
  - **Task(任务)**:MFWHttpTask
  - **Engine(流水线引擎)**: MFWHttpEngine
  - **plugin(插件)**: 1、Request插件:MFWRequestBaseBuilder  2、Response插件:MFWResponseBaseHandler

- **总述**:
  - **1**: 基于流水线的设计思想,请求时创建一个MFWHttpTask(任务)对象,MFWHttpTask里面封装了MFWHttpRequest(request),MFWHttpResponse(response)两个对象。
  
  - **2**: 为MFWHttpTask指定请求类型:(分三种请求类型分别是普通请求,下载请求,上传请求。详见MFWHttpTask.h)。然后为MFWHttpTask中的MFWHttpRequest对象填充必要参数（url,parameters,HttpMethod)等。
  
  - **3**: 将任务(MFWHttpTask)放入流水线引擎中(MFWHttpEngine 单列),请求就会自动执行并会被MFWHttpEngine管理,请求执行完成后MFWHttpEngine会自动填充MFWHttpTask中的MFWHttpResponse对象,你可以用代理随时观察你创建的MFWHttpTask的状态,并在MFWHttpTask完成时候收到CallBack回调。如果是上传或者下载类型的MFWHttpTask你还能获取进度状态,让你的Http请求变得异常的简单。 
  
- **特性**:
  - **插件机制**: 每一个MFWHttpTask对象可以捆绑Request插件(在请求前做一些事情,比如添加公共参数,Xauth认证)和Response插件(在请求完成之后做一些事情,比如通知一些界面改变)。
  
  - **请求一对多管理机制**:设想这样一个场景,你创建了一个下载任务去下载一个资源(假设是:http://www.mafengwo.com/aaa.zip  资源大小为500M)当下载进行到了一半的时候,这个时候又一个任务被创建了,也去下载这一个资源。新创建的任务如果重新去下载话那岂不是一件特别浪费系统资源的事情吗!？。MFWHttpManager实现了一对多的管理机制，当针对于同一资源的MFWHttpTask的任务正在进行当中的时候,如果新创建的MFWHttpTask还是请求正在进行的资源。那么新的请求不会被执行,而是放在队列中监听正在进行的MFWHttpTask的状态,当请求被执行完成的时候他们都能获得相应的回调。这种管理机制，只限于普通请求MFWHttpTask及下载请求的MFWHttpTask。并且你也可以通过设置MFWHttpTask的allowRepeat属性来关闭或者开启这种管理机制。
  
  - **下载支持断点续传**: 支持下载断点续传,无需做专门设置,创建一个下载类型的MFWHttpTask任务,您的下载请求就会自动支持断点续传。(当然还得服务器支持下载断点续传功能)
  
  - **上传支持MultiPart**: 基于MultiPart协议的多文件上传,只需要创建一个上传类型的MFWHttpTask任务,把您需要上传的文件添加到MFWHttpTask对象当中。这样您就能开始MultiPart多文件上传了。

Requirements
==============
iOS 7.0系统及以上。
AFNNetWorking网络库。
