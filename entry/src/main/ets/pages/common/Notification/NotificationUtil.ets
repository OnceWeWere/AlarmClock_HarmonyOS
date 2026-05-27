import { notificationManager } from '@kit.NotificationKit';
import { wantAgent, WantAgent } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';


/** * 通知管理工具类（单例模式） */
export class NotificationUtil {
  private static instance: NotificationUtil; // 静态实例（用来实现单例）：存着唯一的工具对象
  private context: common.UIAbilityContext | null = null;

  private constructor() {
  } // 私有构造函数（防止别人 new NotificationUtil()）

  /** * 获取单例实例：确保一个类在整个程序运行期间只能创建一个对象实例，并且提供一个全局访问点来获取这个实例 */
  public static getInstance(): NotificationUtil {
    if (!NotificationUtil.instance) { // 第一次调用时，instance 是空的
      NotificationUtil.instance = new NotificationUtil(); // 第一次调用时，instance 是空的
    }
    return NotificationUtil.instance;
  }

  /** * 初始化方法（在 EntryAbility.onCreate 中调用 */
  public initialize(context: common.UIAbilityContext): void {
    this.context = context;
    /*    ┌─────────────────────────────────────────────────────┐
        │  想象你要去银行办事：                                 │
        │                                                     │
        │  你: "我要查余额"                                    │
        │  银行: "请出示身份证"                                │
        │  你: 给出身份证                                      │
        │  银行: 好的，帮你查                                  │
        │                                                     │
        │  ─────────────────────────────────────────────────  │
        │                                                     │
        │  context 就是那个"身份证"：                          │
        │                                                     │
        │  你: "我要发通知"                                    │
        │  系统: "请出示 context"                              │
        │  你: 给出 context                                   │
        │  系统: 好的，帮你发通知                              │
        └─────────────────────────────────────────────────────┘*/
  }

  /** * 检查通知是否开启（同步方法） */
  public isNotificationEnabled(): boolean {
    try {
      return notificationManager.isNotificationEnabledSync();
    } catch (err) {
      console.error(`检查通知状态失败: ${(err as BusinessError).message}`);
      return false;
    }
  }

  /** * 请求通知授权 */
  public async requestNotificationPermission(): Promise<boolean> {
    if (!this.context) {
      console.error('NotificationUtil 未初始化');
      return false;
    }

    const isEnabled = this.isNotificationEnabled();
    if (isEnabled) {
      return true;
    }

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

  /**
   * 打开通知设置页面（用于二次授权）
   */
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

  /**
   * 发布普通文本通知
   */
  public async publishTextNotification(
    id: number,
    title: string,
    text: string,
    additionalText?: string
  ): Promise<boolean> {
    const notificationRequest: notificationManager.NotificationRequest = {
      id,
      notificationSlotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title:title,
          text:text,
          additionalText: additionalText ?? ''
        }
      }
    };

    try {
      await notificationManager.publish(notificationRequest);
      return true;
    } catch (err) {
      console.error(`发布通知失败: ${(err as BusinessError).message}`);
      return false;
    }
  }

  /**
   * 发布带跳转意图的通知
   */
  public async publishNotificationWithAction(
    id: number,
    title: string,
    text: string,
    bundleName: string,
    abilityName: string,
    params?: Record<string, Object>
  ): Promise<boolean> {
    // 创建 WantAgent
    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [{
        bundleName,
        abilityName,
        parameters: params ?? {}
      }],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.CONSTANT_FLAG]
    };

    try {
      const wantAgentObj: WantAgent = await wantAgent.getWantAgent(wantAgentInfo);

      const notificationRequest: notificationManager.NotificationRequest = {
        id,
        notificationSlotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: { title, text }
        },
        wantAgent: wantAgentObj
      };

      await notificationManager.publish(notificationRequest);
      return true;
    } catch (err) {
      console.error(`发布带意图通知失败: ${(err as BusinessError).message}`);
      return false;
    }
  }

  /**
   * 取消指定通知
   */
  public async cancelNotification(id: number, label?: string): Promise<boolean> {
    try {
      await notificationManager.cancel(id, label);
      return true;
    } catch (err) {
      console.error(`取消通知失败: ${(err as BusinessError).message}`);
      return false;
    }
  }

  /**
   * 取消所有通知
   */
  public async cancelAllNotifications(): Promise<boolean> {
    try {
      await notificationManager.cancelAll();
      return true;
    } catch (err) {
      console.error(`取消所有通知失败: ${(err as BusinessError).message}`);
      return false;
    }
  }

  /**
   * 设置角标数量
   */
  public async setBadgeNumber(number: number): Promise<boolean> {
    try {
      await notificationManager.setBadgeNumber(number);
      return true;
    } catch (err) {
      console.error(`设置角标失败: ${(err as BusinessError).message}`);
      return false;
    }
  }
}


export default NotificationUtil.getInstance();
// NotificationUtil 的单例实例作为默认导出，使得其他模块可以直接导入使用，无需手动调用 getInstance()
// 目的	    说明
// 简化导入	使用时无需写 NotificationUtil.getInstance()
// 统一实例	确保全局使用的是同一个实例
// 便捷访问	导入后直接使用，代码更简洁
// ┌─────────────────────────────────────────────────────────┐
// │                    应用全局                              │
// │                                                         │
// │   EntryAbility.ets ──┐                                  │
// │   Index.ets ─────────┼──► 都使用同一个 NotificationUtil │
// │   SettingPage.ets ───┘                                  │
// │                                                         │
// └─────────────────────────────────────────────────────────┘