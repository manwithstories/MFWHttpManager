MFWHttpManager <a href="#介绍">简介</a>
==============
[![Support](https://img.shields.io/badge/support-iOS%207%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/)&nbsp;
[![Support](https://img.shields.io/badge/support-AFNetWorking-blue.svg)](https://www.apple.com/nl/ios/)&nbsp;


Introduction
==============

基于AFNetworking(AFURLSessionManager)的一个高度封装的Http请求管理库。


Features
==============
- **总述**:
  - **1**: 基于流水线的设计思想,请求时创建一个MFWHttpTask(任务)对象,MFWHttpTask里面封装了MFWHttpRequest(request),MFWHttpResponse(response)两个对象。
  
  - **2**: 为MFWHttpTask指定请求类型:(分三种请求类型分别是普通请求,下载请求,上传请求。详见MFWHttpTask.h)。然后为MFWHttpTask中的MFWHttpRequest对象填充必要参数（url,parameters,HttpMethod)等。
  
  - **3**: 将任务(MFWHttpTask)放入流水线引擎中(MFWHttpEngine 单列),请求就会自动执行并会被MFWHttpEngine管理,请求执行完成后MFWHttpEngine会自动填充MFWHttpTask中的MFWHttpResponse对象,你可以用代理随时观察你创建的MFWHttpTask的状态,并在MFWHttpTask完成时候收到CallBack回调。如果是上传或者下载类型的MFWHttpTask你还能获取进度状态,让你的Http请求变得异常的简单。 
  
- **特性**:
  - **插件机制**: 每一个MFWHttpTask对象可以捆绑Request插件(在请求前做一些事情,比如添加公共参数,Xauth认证)和Response插件(在请求完成之后做一些事情,比如通知一些界面改变)。
  
  - **一对多管理机制**: 假如你创建了N个MFWHttpTask对象同时访问同一个资源地址(www.mafengwo.com/poilist.php?page=1&size=20)。 请求URL,参数,HttpMethod完全一样,当第一个MFWHttpTask没有被执行完成的时候,MFWHttpEngine不会发送N个请求,只会发送一个网络请求。但是剩下的MFWHttpTask都能监听到请求的状态,也都会执行相应的回调。
  
  - **下载支持断点续传**: 支持下载断点续传,无需做专门设置,创建一个下载类型的MFWHttpTask任务,您的下载请求就会自动支持断点续传。(当然还得服务器支持下载断点续传功能)
  
  - **上传支持MultiPart**: 基于MultiPart协议的多文件上传,只需要创建一个上传类型的MFWHttpTask任务,把您需要上传的文件添加到MFWHttpTask对象当中。这样您就能开始MultiPart多文件上传了。

Requirements
==============
iOS 7.0系统及以上。
AFNNetWorking网络库。
