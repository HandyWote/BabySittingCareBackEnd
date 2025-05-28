# 微信小程序接口文档

## 基础信息
- **域名**：pinf.top
- **服务器公网IP**：8.138.224.38

## 错误码说明
- **401**：未授权或token无效
- **400**：请求参数错误
- **500**：服务器内部错误

## 接口列表

### 1. 登录接口
- **接口URL**：https://pinf.top/api/login
- **请求方式**：POST
- **接口描述**：使用微信临时登录凭证进行用户登录

#### 请求参数
| 参数名 | 类型   | 必须 | 说明               |
|--------|--------|------|--------------------|
| code   | string | 是   | 微信登录临时凭证   |

#### 响应数据
| 字段名       | 类型   | 说明               |
|--------------|--------|--------------------|
| success      | boolean| 请求是否成功       |
| userinfo     | object | 用户信息对象       |
| role         | string | 用户角色，'user'或'doctor' |
| openid       | string | 用户唯一标识       |
| session_key  | string | 会话密钥           |
| childinfo    | array  | 儿童信息数组       |
| token        | string | 认证令牌           |
| message      | string | 错误信息（失败时） |

### 2. 获取儿童信息接口
- **接口URL**：https://pinf.top/api/getChildInfo
- **请求方式**：GET
- **接口描述**：根据用户openid获取儿童信息

#### 请求参数
| 参数名 | 类型   | 必须 | 说明               |
|--------|--------|------|--------------------|
| openid | string | 是   | 用户的唯一标识     |

#### 响应数据
| 字段名       | 类型   | 说明               |
|--------------|--------|--------------------|
| success      | boolean| 请求是否成功       |
| childinfo    | array  | 儿童信息数组       |

### childInfo 数组结构说明

| 参数名         | 类型   | 必须 | 说明                                                         |
| -------------- | ------ | ---- | ------------------------------------------------------------ |
| name           | String | 是   | 宝宝的姓名                                                   |
| birthDate      | String | 是   | 宝宝的出生日期，格式：`YYYY-MM-DD`                           |
| gender         | String | 是   | 宝宝的性别，取值为 `"男"` 或 `"女"`                          |
| gestationalAge | Number | 是   | 孕周（例如：`40`）                                           |
| growthRecords  | Array  | 否   | 生长记录数组，包含身高、体重等数据（若无记录可为空数组或省略） |

---

### growthRecords 数组中的对象结构

| 参数名            | 类型   | 必须 | 说明                          |
| ----------------- | ------ | ---- | ----------------------------- |
| date              | String | 是   | 记录日期，格式：`YYYY-MM-DD`  |
| ageInMonths       | Number | 是   | 月龄（例如：`6` 表示6个月大） |
| ageInWeeks        | Number | 是   | 周龄（例如：`24` 表示24周大） |
| height            | Number | 是   | 身高，单位：厘米（cm）        |
| weight            | Number | 是   | 体重，单位：千克（kg）        |
| headCircumference | Number | 是   | 头围，单位：厘米（cm）        |

### 3. 同步数据到服务器

- **接口URL**：https://pinf.top/api/syncData
- **请求方式**：POST
- **接口描述**：将本地数据同步到服务器

#### 请求参数
| 参数名 | 类型   | 必须 | 说明               |
|--------|--------|------|--------------------|
| openid | string | 是   | 用户的唯一标识     |
| token  | string | 是   | 认证令牌           |
| data   | array  | 是   | 待同步的数据队列   |

#### data数组项结构
| 字段名     | 类型         | 说明               |
|------------|--------------|--------------------|
| type       | string       | 数据类型，如'childInfo' |
| data       | object/array | 实际数据内容       |
| timestamp  | number       | 数据创建时间戳     |

#### 响应数据
| 字段名 | 类型   | 说明               |
|--------|--------|--------------------|
| success| boolean| 请求是否成功       |

### 4. 获取在线课程数据
- **接口URL**：https://pinf.top/api/getOnlineClassData
- **请求方式**：GET
- **接口描述**：获取在线课堂的所有视频和文章列表（前端将只显示前3个）

#### 请求参数
| 参数名 | 类型   | 必须 | 说明               |
|--------|--------|------|--------------------|
| openid | string | 是   | 用户的唯一标识     |
| token  | string | 是   | 认证令牌           |

#### 响应数据
| 字段名       | 类型   | 说明               |
|--------------|--------|--------------------|
| success      | boolean| 请求是否成功       |
| videoGroups  | array  | 所有视频数据       |
| articleGroups| array  | 所有文章数据       |
| message      | string | 错误信息（请求失败时） |

### 5. 获取视频详情
- **接口URL**：https://pinf.top/api/getVideoDetail
- **请求方式**：GET
- **接口描述**：获取视频详细信息

#### 请求参数
| 参数名 | 类型   | 必须 | 说明               |
|--------|--------|------|--------------------|
| id     | number | 是   | 视频ID             |
| openid | string | 是   | 用户的唯一标识     |
| token  | string | 是   | 认证令牌           |

#### 响应数据
| 字段名       | 类型   | 说明               |
|--------------|--------|--------------------|
| success      | boolean| 请求是否成功       |
| videoInfo    | object | 视频详细信息       |
| message      | string | 错误信息（请求失败时） |

#### videoInfo对象结构
| 字段名       | 类型   | 说明               |
|--------------|--------|--------------------|
| id           | number | 视频ID             |
| title        | string | 视频标题           |
| description  | string | 视频描述           |
| videoUrl     | string | 视频URL            |
| coverUrl     | string | 封面图URL          |
| views        | number | 观看次数           |
| publishDate  | string | 发布日期           |
| tags         | array  | 标签数组           |

### 6. 获取文章详情
- **接口URL**：https://pinf.top/api/getArticleDetail
- **请求方式**：GET
- **接口描述**：获取文章详细信息

#### 请求参数
| 参数名 | 类型   | 必须 | 说明               |
|--------|--------|------|--------------------|
| id     | number | 是   | 文章ID             |
| openid | string | 是   | 用户的唯一标识     |
| token  | string | 是   | 认证令牌           |

#### 响应数据
| 字段名       | 类型   | 说明               |
|--------------|--------|--------------------|
| success      | boolean| 请求是否成功       |
| articleInfo  | object | 文章详细信息       |
| message      | string | 错误信息（请求失败时） |

#### articleInfo对象结构
| 字段名       | 类型   | 说明               |
|--------------|--------|--------------------|
| id           | number | 文章ID             |
| title        | string | 文章标题           |
| content      | string | 文章内容(HTML格式) |
| coverUrl     | string | 封面图URL          |
| author       | string | 作者               |
| publishDate  | string | 发布日期           |
| tags         | array  | 标签数组           |

### 7. 搜索在线内容
- **接口URL**：https://pinf.top/api/searchOnlineContent
- **请求方式**：GET
- **接口描述**：搜索在线课堂的视频和文章（前端将只显示前3个）

#### 请求参数
| 参数名 | 类型   | 必须 | 说明               |
|--------|--------|------|--------------------|
| keyword| string | 是   | 搜索关键词         |
| openid | string | 是   | 用户的唯一标识     |
| token  | string | 是   | 认证令牌           |

#### 响应数据
| 字段名       | 类型   | 说明               |
|--------------|--------|--------------------|
| success      | boolean| 请求是否成功       |
| videoGroups  | array  | 匹配的所有视频数据 |
| articleGroups| array  | 匹配的所有文章数据 |
| message      | string | 错误信息（请求失败时） |

### 8. 获取预约信息
- **接口URL**：https://pinf.top/api/getAppointmentInfo
- **请求方式**：GET
- **接口描述**：获取预约信息

#### 请求参数
| 参数名 | 类型   | 必须 | 说明               |
|--------|--------|------|--------------------|
| openid | string | 是   | 用户唯一标识       |
| childId| string | 是   | 宝宝ID             |

#### 响应数据
| 参数名           | 类型   | 说明               |
|------------------|--------|--------------------|
| success          | Boolean| 请求是否成功       |
| appointmentInfo   | Object | 复诊信息对象       |

### 9 同步预约信息

- **接口URL**: https://pinf.top/api/syncData  
- **请求方式**: POST  
- **接口描述**: 同步复诊预约信息到服务器  

## 请求参数

| 参数名 | 类型   | 必须 | 说明                                             |
| ------ | ------ | ---- | ------------------------------------------------ |
| opendd | String | 是   | 用户唯一标识                                     |
| token  | String | 是   | 用户认证令牌                                     |
| data   | Array  | 是   | 待同步的复诊记录数组，包含医院、科室、日期等信息 |

## 响应数据

| 参数名  | 类型    | 说明                                              |
| ------- | ------- | ------------------------------------------------- |
| success | Boolean | 请求是否成功处理。true 表示成功，false 表示失败。 |
| message | String  | 响应消息。包含成功或失败的详细信息。              |

---

### 返回值说明（data数组中的对象结构）

| 参数名          | 类型   | 说明                                           |
| --------------- | ------ | ---------------------------------------------- |
| id              | String | 复诊记录唯一ID                                 |
| hospitalName    | String | 医院名称                                       |
| department      | String | 科室名称                                       |
| appointmentDate | String | 复诊日期，格式：YYYY-MM-DD                     |
| reminderDays    | Number | 提前提醒天数                                   |
| notes           | String | 备注信息                                       |
| status          | String | 状态：'pending'(待提醒) 或 'completed'(已完成) |

### 11. 同步用户浏览记录等数据

- **接口URL**：https://pinf.top/api/syncData
- **请求方式**：POST
- **接口描述**：同步用户浏览记录等数据

#### 请求参数
| 参数名 | 类型   | 必须 | 说明               |
|--------|--------|------|--------------------|
| openid | string | 是   | 用户的唯一标识     |
| token  | string | 是   | 认证令牌           |
| data   | array  | 是   | 待同步的数据队列   |

#### data数组项结构
| 字段名 | 类型         | 说明                           |
|--------|--------------|--------------------------------|
| type   | string       | 数据类型，如'videoView'、'articleView'或'onlineClassView' |
| data   | object       | 实际数据内容                   |
| timestamp| number     | 数据创建时间戳                 |

#### 响应数据
| 字段名 | 类型   | 说明               |
|--------|--------|--------------------|
| success| boolean| 请求是否成功       |

### 12. 获取聊天历史
- **接口URL**：https://pinf.top/api/syncData
- **请求方式**：GET
- **接口描述**：获取聊天历史

#### 请求参数
| 参数名 | 类型   | 必须 | 说明               |
|--------|--------|------|--------------------|
| openid | string | 是   | 用户的唯一标识     |
| type   | string | 是   | 固定为 `chatHistory`|
| userId | string | 是   | 用户的唯一标识     |

#### 响应数据
| 字段名       | 类型   | 说明               |
|--------------|--------|--------------------|
| success      | boolean| 请求是否成功       |
| chatHistory  | object | 聊天历史对象       |

#### 聊天历史对象结构
| 字段名         | 类型   | 说明               |
|----------------|--------|--------------------|
| userId         | string | 用户ID             |
| messageList    | array  | 消息列表，每个元素为消息对象 |
| lastUpdateTime | number | 最后更新时间戳     |

#### 消息对象结构
| 字段名 | 类型   | 说明               |
|--------|--------|--------------------|
| id     | string | 消息的唯一ID       |
| type   | string | 消息类型（'user' 或 'ai'）|
| content| string | 消息内容           |
| time   | number | 消息发送时间的时间戳|
| status | string | 消息状态（'sent', 'failed'）|

### 13. 保存聊天消息
- **接口URL**：未提供
- **请求方式**：POST
- **接口描述**：保存用户的聊天消息到本地，并将其加入同步队列

#### 参数
| 参数名 | 类型   | 说明               |
|--------|--------|--------------------|
| userId | string | 用户的唯一标识     |
| message| object | 消息对象 (结构同上) |

#### 返回值 Object
| 字段名       | 类型   | 说明               |
|--------------|--------|--------------------|
| success      | boolean| 操作是否成功       |
| chatHistory   | object | 更新后的聊天历史对象|

### 14. 请求AI响应
- **接口URL**：https://example.com/ai-api
- **请求方式**：POST
- **接口描述**：向AI服务发送请求并获取响应

#### 请求参数
| 参数名 | 类型   | 必须 | 说明               |
|--------|--------|------|--------------------|
| openid | String | 是   | 用户唯一标识，用于区分不同用户或进行个性化服务。 |
| question| String | 是   | 用户提出的问题文本。 |

#### 响应数据
| 参数名 | 类型   | 说明                                       |
|--------|--------|--------------------------------------------|
| success| Boolean| 请求是否成功处理。`true` 表示成功，`false` 表示失败。 |
| answer | String | AI服务返回的回答文本。仅在 `success` 为 `true` 时有效。 |
| message| String | 错误信息。仅在 `success` 为 `false` 时有效。     |

