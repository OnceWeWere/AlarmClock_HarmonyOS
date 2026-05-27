## 解释 `NotificationUtil` 工具类的每个部分

------

## 一、类的整体结构

```typescript
export class NotificationUtil {
  private static instance: NotificationUtil;        // 单例实例
  private context: common.UIAbilityContext | null = null;  // 应用上下文

  private constructor() {}  // 私有构造函数，防止外部 new
  
  // ... 各种方法
}
```



### 为什么用单例模式？



![img](http://snap/assets/copy-c360a84f.svg)

![img](http://snap/assets/insert-852d282d.svg)

![img](http://snap/assets/new-3f6cd788.svg)

```undefined
┌─────────────────────────────────────────────────────────┐
│  不用单例的情况：                                        │
│  ┌─────────┐   ┌─────────┐   ┌─────────┐               │
│  │ 页面 A   │   │ 页面 B   │   │ 页面 C   │               │
│  │ new Util│   │ new Util│   │ new Util│               │
│  └────┬────┘   └────┬────┘   └────┬────┘               │
│       ↓             ↓             ↓                    │
│  ┌─────────┐   ┌─────────┐   ┌─────────┐               │
│  │ 实例 1  │   │ 实例 2  │   │ 实例 3  │  ← 重复创建！  │
│  └─────────┘   └─────────┘   └─────────┘               │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  用单例的情况：                                          │
│  ┌─────────┐   ┌─────────┐   ┌─────────┐               │
│  │ 页面 A   │   │ 页面 B   │   │ 页面 C   │               │
│  │getInstance│  │getInstance│  │getInstance│             │
│  └────┬────┘   └────┬────┘   └────┬────┘               │
│       └─────────────┼─────────────┘                    │
│                     ↓                                   │
│              ┌─────────────┐                            │
│              │  唯一实例   │  ← 全局共享！              │
│              └─────────────┘                            │
└─────────────────────────────────────────────────────────┘
```



------

## 二、获取单例实例



![img](http://snap/assets/copy-c360a84f.svg)

![img](http://snap/assets/insert-852d282d.svg)

![img](http://snap/assets/new-3f6cd788.svg)

```typescript
public static getInstance(): NotificationUtil {
  if (!NotificationUtil.instance) {
    NotificationUtil.instance = new NotificationUtil();
  }
  return NotificationUtil.instance;
}
```



**作用**：获取全局唯一的工具类实例

**执行流程**：

```undefined
调用 getInstance()
      ↓
检查 instance 是否存在？
      ↓
   ┌──┴──┐
   ↓     ↓
  不存在  存在
   ↓     ↓
 创建新的  直接返回
   ↓     ↓
   └──┬──┘
      ↓
   返回实例
```



**使用方式**：

```typescript
// 获取实例
const util = NotificationUtil.getInstance();

// 或者导出时直接返回实例（更简洁）
export default NotificationUtil.getInstance();

// 然后直接使用
import NotificationUtil from './utils/NotificationUtil';
NotificationUtil.publishTextNotification(...);
```



------

## 三、初始化方法

```typescript
public initialize(context: common.UIAbilityContext): void {
  this.context = context;
}
```



**作用**：保存应用上下文，后续操作需要用到

**为什么需要 context？**

```undefined
┌─────────────────────────────────────────────────────────┐
│  context 的用途：                                        │
│                                                         │
│  1. requestEnableNotification(context) ← 请求通知授权   │
│  2. openNotificationSettings(context)  ← 打开设置页面   │
│  3. 获取应用信息、资源路径等                             │
└─────────────────────────────────────────────────────────┘
```



**调用时机**：在应用启动时（EntryAbility.onCreate）

```typescript
// EntryAbility.ets
onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
  NotificationUtil.initialize(this.context);  // ← 这里初始化
}
```



------

## 四、检查通知是否开启

```typescript
public isNotificationEnabled(): boolean {
  try {
    return notificationManager.isNotificationEnabledSync();
  } catch (err) {
    console.error(`检查通知状态失败: ${(err as BusinessError).message}`);
    return false;
  }
}
```



**作用**：检查用户是否允许应用发送通知

**返回值**：

- `true`：用户已授权
- `false`：用户未授权或检查出错

**流程图**：

```undefined
调用 isNotificationEnabled()
           ↓
调用系统 API: isNotificationEnabledSync()
           ↓
      ┌────┴────┐
      ↓         ↓
    成功       失败
      ↓         ↓
  返回状态    捕获异常
              ↓
           返回 false
```



------

## 五、请求通知授权

```typescript
public async requestNotificationPermission(): Promise<boolean> {
  // 步骤1：检查 context 是否存在
  if (!this.context) {
    console.error('NotificationUtil 未初始化');
    return false;
  }
  
  // 步骤2：检查是否已授权
  const isEnabled = this.isNotificationEnabled();
  if (isEnabled) {
    return true;  // 已授权，直接返回
  }

  // 步骤3：请求授权
  try {
    await notificationManager.requestEnableNotification(this.context);
    return true;
  } catch (err) {
    const error = err as BusinessError;
    if (error.code === 1600004) {
      console.warn('用户拒绝了通知授权');
    } else {
      console.error(`请求通知授权失败: ${error.message}`);
    }
    return false;
  }
}
```



**作用**：请求用户授权通知权限

**执行流程**：

```undefined
requestNotificationPermission()
           ↓
    context 存在？ ──否──→ 返回 false
           ↓是
    已授权？ ──是──→ 返回 true
           ↓否
    弹出授权弹窗
           ↓
      ┌────┴────┐
      ↓         ↓
   用户同意    用户拒绝
      ↓         ↓
  返回 true   错误码 1600004
                ↓
             返回 false
```



**错误码说明**：

| 错误码  | 含义         |
| ------- | ------------ |
| 1600004 | 用户拒绝授权 |
| 1600001 | 内部错误     |
| 1600003 | 服务连接失败 |

------

## 六、打开通知设置页面



![img](http://snap/assets/copy-c360a84f.svg)

![img](http://snap/assets/insert-852d282d.svg)

![img](http://snap/assets/new-3f6cd788.svg)

```typescript
public async openNotificationSettings(): Promise<boolean> {
  if (!this.context) {
    return false;
  }
  try {
    await notificationManager.openNotificationSettings(this.context);
    return true;
  } catch (err) {
    console.error(`打开通知设置失败: ${(err as BusinessError).message}`);
    return false;
  }
}
```



**作用**：当用户拒绝授权后，引导用户去系统设置中手动开启

**使用场景**：

```undefined
┌─────────────────────────────────────────────────────────┐
│  第一次请求授权 → 用户拒绝                               │
│        ↓                                                │
│  再次调用 requestEnableNotification() 不会弹窗          │
│        ↓                                                │
│  此时需要调用 openNotificationSettings()                │
│        ↓                                                │
│  跳转到系统设置页面，让用户手动开启                       │
└─────────────────────────────────────────────────────────┘
```



------

## 七、发布普通文本通知

```typescript
public async publishTextNotification(
  id: number,              // 通知ID（用于后续取消）
  title: string,           // 通知标题
  text: string,            // 通知内容
  additionalText?: string  // 附加文本（可选）
): Promise<boolean> {
  
  // 构造通知请求对象
  const notificationRequest: notificationManager.NotificationRequest = {
    id,
    notificationSlotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
    content: {
      notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
      normal: {
        title,
        text,
        additionalText: additionalText ?? ''
      }
    }
  };

  // 发布通知
  try {
    await notificationManager.publish(notificationRequest);
    return true;
  } catch (err) {
    console.error(`发布通知失败: ${(err as BusinessError).message}`);
    return false;
  }
}
```



**通知结构图**：

```undefined
┌─────────────────────────────────────┐
│  通知栏                              │
│  ┌─────────────────────────────────┐│
│  │ 🔔 闹钟提醒         ← title      ││
│  │    您设定的闹钟时间已到 ← text    ││
│  │    点击查看详情   ← additionalText││
│  └─────────────────────────────────┘│
└─────────────────────────────────────┘
```



**SlotType 说明**：

| 类型                 | 说明     | 提醒方式  |
| -------------------- | -------- | --------- |
| SOCIAL_COMMUNICATION | 社交通信 | 铃声+震动 |
| SERVICE_INFORMATION  | 服务提醒 | 铃声+震动 |
| CONTENT_INFORMATION  | 内容资讯 | 无声音    |
| OTHER_TYPES          | 其他     | 无声音    |

------

## 八、发布带跳转意图的通知

```typescript
public async publishNotificationWithAction(
  id: number,
  title: string,
  text: string,
  bundleName: string,      // 应用包名
  abilityName: string,     // 要跳转的 Ability
  params?: Record<string, Object>  // 传递的参数
): Promise<boolean> {
  
  // 步骤1：创建 WantAgent（定义点击后的行为）
  const wantAgentInfo: wantAgent.WantAgentInfo = {
    wants: [{
      bundleName,      // 跳转到哪个应用
      abilityName,     // 跳转到哪个页面
      parameters: params ?? {}  // 携带的参数
    }],
    operationType: wantAgent.OperationType.START_ABILITY,  // 操作类型
    requestCode: 0,
    wantAgentFlags: [wantAgent.WantAgentFlags.CONSTANT_FLAG]
  };

  try {
    // 步骤2：获取 WantAgent 对象
    const wantAgentObj: WantAgent = await wantAgent.getWantAgent(wantAgentInfo);
    
    // 步骤3：构造通知请求
    const notificationRequest: notificationManager.NotificationRequest = {
      id,
      notificationSlotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: { title, text }
      },
      wantAgent: wantAgentObj  // ← 绑定跳转意图
    };

    // 步骤4：发布通知
    await notificationManager.publish(notificationRequest);
    return true;
  } catch (err) {
    console.error(`发布带意图通知失败: ${(err as BusinessError).message}`);
    return false;
  }
}
```



**WantAgent 是什么？**



![img](http://snap/assets/copy-c360a84f.svg)

![img](http://snap/assets/insert-852d282d.svg)

![img](http://snap/assets/new-3f6cd788.svg)

```undefined
┌─────────────────────────────────────────────────────────┐
│  WantAgent = "行为意图"                                  │
│                                                         │
│  它封装了用户点击通知后要执行的动作：                      │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  用户点击通知                                     │   │
│  │         ↓                                         │   │
│  │  系统触发 WantAgent                               │   │
│  │         ↓                                         │   │
│  │  执行预设动作（如：跳转到指定页面）                 │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```



**使用示例**：



![img](http://snap/assets/copy-c360a84f.svg)

![img](http://snap/assets/insert-852d282d.svg)

![img](http://snap/assets/new-3f6cd788.svg)

```typescript
// 点击通知后跳转到闹钟详情页
await NotificationUtil.publishNotificationWithAction(
  1,                                    // 通知ID
  '闹钟提醒',                           // 标题
  '7:00 起床闹钟',                      // 内容
  'com.example.clock',                  // 应用包名
  'AlarmDetailAbility',                 // 目标页面
  { alarmId: '123' }                    // 传递参数
);
```



------

## 九、取消通知

```typescript
// 取消单条通知
public async cancelNotification(id: number, label?: string): Promise<boolean> {
  try {
    await notificationManager.cancel(id, label);
    return true;
  } catch (err) {
    console.error(`取消通知失败: ${(err as BusinessError).message}`);
    return false;
  }
}

// 取消所有通知
public async cancelAllNotifications(): Promise<boolean> {
  try {
    await notificationManager.cancelAll();
    return true;
  } catch (err) {
    console.error(`取消所有通知失败: ${(err as BusinessError).message}`);
    return false;
  }
}
```



**使用场景**：



![img](http://snap/assets/copy-c360a84f.svg)

![img](http://snap/assets/insert-852d282d.svg)

![img](http://snap/assets/new-3f6cd788.svg)

```typescript
// 场景1：闹钟关闭后，取消对应通知
await NotificationUtil.cancelNotification(1);

// 场景2：用户退出应用，清除所有通知
await NotificationUtil.cancelAllNotifications();
```



------

## 十、设置角标

```typescript
public async setBadgeNumber(number: number): Promise<boolean> {
  try {
    await notificationManager.setBadgeNumber(number);
    return true;
  } catch (err) {
    console.error(`设置角标失败: ${(err as BusinessError).message}`);
    return false;
  }
}
```



**效果展示**：



![img](http://snap/assets/copy-c360a84f.svg)

![img](http://snap/assets/insert-852d282d.svg)

![img](http://snap/assets/new-3f6cd788.svg)

```undefined
┌─────────┐     ┌─────────┐     ┌─────────┐
│  📱     │     │  📱     │     │  📱     │
│  App    │     │  App ③  │     │  App ⑧  │
└─────────┘     └─────────┘     └─────────┘
    ↓               ↓               ↓
setBadgeNumber(0)  setBadgeNumber(3)  setBadgeNumber(8)
```



------

## 十一、完整使用流程图



```undefined
┌─────────────────────────────────────────────────────────────────┐
│                        应用启动                                  │
│                           ↓                                      │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  EntryAbility.onCreate()                                 │   │
│  │  NotificationUtil.initialize(this.context)              │   │
│  │  NotificationUtil.requestNotificationPermission()       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                           ↓                                      │
│                      应用运行中                                  │
│                           ↓                                      │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  需要发送通知时：                                         │   │
│  │  NotificationUtil.publishTextNotification(...)          │   │
│  │  或                                                       │   │
│  │  NotificationUtil.publishNotificationWithAction(...)    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                           ↓                                      │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  需要取消通知时：                                         │   │
│  │  NotificationUtil.cancelNotification(id)                │   │
│  │  或                                                       │   │
│  │  NotificationUtil.cancelAllNotifications()              │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```



------

如果还有哪个部分不清楚，可以继续问我！