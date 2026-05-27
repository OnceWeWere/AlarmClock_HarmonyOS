import NotificationUtil from '../common/Notification/NotificationUtil';
import PreferencesUtil, { PreferencesUtil as PrefClass } from '../common/Preferences/PreferencesUtil';
import { ReturnAlarmData } from '../common/types/NewAlarmClock_Types';

@Preview
@Component
struct AIarmList {
  scroller: Scroller = new Scroller();
  @Link NewAlarmClock_resultData: ReturnAlarmData[];
  @Consume('NavPathStack') pageStack: NavPathStack; // 使用 @Consume 接收父组件提供的数据
  @State TempHour: number = 0;
  @State TempMinute: number = 0;

  AlarmClockDetailsPrompt(alarm: ReturnAlarmData): string {
    let result = ''
    let getGreeting = (hour: number): string => { // 问好
      if (hour < 9) {
        return '早上好';
      } else if (hour < 11) {
        return '上午好';
      } else if (hour < 13) {
        return '中午好';
      } else if (hour < 18) {
        return '下午好';
      } else {
        return '闹钟';
      }
    }
    const greetings: string = getGreeting(Number(alarm.hour))
    result = `${greetings}`
    return result;
  }

  CalculateTheNextTime(): string {
    return `23333 后响铃`
  }

  build() {
    Scroll(this.scroller) {
      Column({ space: 10 }) {
        ForEach(this.NewAlarmClock_resultData, (alarm: ReturnAlarmData, index: number) => {
          Row() {
            Column({ space: 5 }) {
              Text(`${Number(alarm.hour) <= 9 ? 0 + alarm.hour : alarm.hour}:${Number(alarm.minute) <= 9 ?
                0 + alarm.minute : alarm.minute}`)
                .fontSize(24)
                .width('100%')
                .fontWeight(FontWeight.Medium)
              Text(this.AlarmClockDetailsPrompt(alarm))
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
            }

            .width('50%')
            .alignItems(HorizontalAlign.Start)

            Toggle({ type: ToggleType.Switch, isOn: alarm.isOpen }).id(`toggle_AIarmList_${index}`)
              .onChange((isOn: boolean) => {
                if (isOn) {
                  this.getUIContext().getPromptAction().openToast({
                    // 推荐写法（避免 UI 上下文不明确）
                    message: this.CalculateTheNextTime()
                  });
                  alarm.isOpen = true;

                } else {

                  this.getUIContext().getPromptAction().openToast({
                    message: 'aiarmclock is off'
                  });
                  alarm.isOpen = false;
                }

                // 关闭闹钟或打开闹钟写入preferences
                PreferencesUtil.put(PrefClass.STORE_NAME, this.NewAlarmClock_resultData)
                console.log(`当Toggle切换的时 读取preferences：${JSON.stringify(PreferencesUtil.get(PrefClass.STORE_NAME,
                  PrefClass.defaultValue))}`)
              })
          }
          .height(62)
          .width('100%')
          .borderRadius(18)
          .padding({ left: 10, right: 10 })
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
          .backgroundColor(Color.White)
          .onClick(() => {
            // 带返回回调的跳转
            this.pageStack.pushPathByName('EditAlarmClock', {
              hour: alarm.hour,
              minute: alarm.minute,
              repeat: alarm.repeat,
              statutoryHoliday: alarm.statutoryHoliday,
              alarmRingtone: alarm.alarmRingtone,
              alarmClockName: alarm.alarmClockName,
              AlarmDuration: alarm.AlarmDuration,
              RepeatingInterval: alarm.RepeatingInterval, // 再响间隔：响铃间隔的时间，重复次数
              isOpen: alarm.isOpen
            } as ReturnAlarmData, (PopInfo) => {

              const result = PopInfo.result as [boolean, ReturnAlarmData]
              const isDel = result[0];
              const updateAIarm = result[1];

              console.log(`是否删除:${isDel}`)
              console.log('编辑闹钟页 返回的结果:', JSON.stringify(PopInfo.result))
              console.log(`编辑闹钟页 返回的时间:${updateAIarm.hour}:${updateAIarm.minute}`)
              console.log(`NewAlarmClock_resultData[${index}]:${this.NewAlarmClock_resultData[index].hour},${this.NewAlarmClock_resultData[index].minute}`)

              // ArkUI 的响应式规则：
              // 对于 @State 和 @Link 修饰的数组/对象，必须替换整个数组或整个对象才能触发 UI 刷新
              // 直接修改数组元素或对象的属性不会触发 UI 刷新
              if (isDel) {
                this.NewAlarmClock_resultData = this.NewAlarmClock_resultData.filter((item, i) => i !==
                  index) // filter 会遍历数组的每个元素，返回满足条件的元素组成的新数组。 true → 保留这个元素 回调函数返回 false → 丢弃这个元素
              } else {
                this.NewAlarmClock_resultData =
                  this.NewAlarmClock_resultData.map((item, i) => { // map 会遍历数组的每个元素，根据回调函数的返回值创建一个新数组
                    if (i === index) {
                      const newItem: ReturnAlarmData = {
                        // 新对象，新引用 ---- ！！！数组引用变化，才能触发 UI 刷新！！！
                        hour: updateAIarm.hour,
                        minute: updateAIarm.minute,
                        repeat: item.repeat,
                        statutoryHoliday: item.statutoryHoliday,
                        alarmRingtone: item.alarmRingtone,
                        alarmClockName: item.alarmClockName,
                        AlarmDuration: item.AlarmDuration,
                        RepeatingInterval: item.RepeatingInterval,
                        isOpen: item.isOpen
                      }
                      return newItem
                    }
                    return item
                  })
              }

              // 编辑页面返回后 写入preferences
              PreferencesUtil.put(PrefClass.STORE_NAME, this.NewAlarmClock_resultData)
              console.log(`编辑闹钟后 读取preferences：${JSON.stringify(PreferencesUtil.get(PrefClass.STORE_NAME,
                PrefClass.defaultValue))}`)
            })
          })
        })
      }
    }
    .width('92%')
    .layoutWeight(1)
    .padding({ top: 20 })
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .scrollable(ScrollDirection.Vertical)
    .edgeEffect(EdgeEffect.Spring)
  }
}

export default AIarmList