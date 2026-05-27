import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { notificationManager } from '@kit.NotificationKit';


// 闹钟提醒（每天固定时间）
export async function setAlarmReminder(hour: number, minute: number): Promise<number> {
  let alarm: reminderAgentManager.ReminderRequestAlarm = {
    reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_ALARM, //提醒类型为闹钟类型
    hour: hour,
    minute: minute,
    daysOfWeek: [1, 2, 3, 4, 5], // 周一到周五
    title: '起床闹钟',
    content: '该起床了！',
    actionButton: [
      {
        title: '关闭',
        type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CLOSE
      },
      {
        title: '稍后提醒',
        type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_SNOOZE
      }
    ],
    wantAgent: {
      pkgName: 'com.example.myapp',
      abilityName: 'EntryAbility'
    },
    ringDuration: 30, // 响铃时长（秒）
    snoozeTimes: 3, // 延迟提醒次数
    timeInterval: 300, // 延迟提醒间隔（秒）
    notificationId: 100,
    slotType: notificationManager.SlotType.CONTENT_INFORMATION
  };

  try {
    let reminderId = await reminderAgentManager.publishReminder(alarm);
    console.info(`闹钟发布成功，ID: ${reminderId}`);
    return reminderId;
  } catch (err) {
    console.error(`闹钟发布失败: ${(err as BusinessError).message}`);
    return -1;
  }
}