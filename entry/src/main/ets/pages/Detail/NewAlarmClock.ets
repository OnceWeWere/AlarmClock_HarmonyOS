import { ReturnAlarmData } from "../common/types/NewAlarmClock_Types";
import { setAlarmReminder } from '../common/Notification/ReminderAgentUtil';

@Preview
@Component
struct NewAlarmClock {
  @State UserSelectHour: string = new Date().getHours().toString();
  @State UserSelectMinute: string = new Date().getMinutes().toString();
  scroller: Scroller = new Scroller();
  private selectedTime: Date = new Date()
  @Consume('NavPathStack') pageStack: NavPathStack; // 使用 @Consume 接收父组件提供的数据

  @Styles
  ListStyle(){
    .width('100%')
    .borderRadius(16)
    .padding({
      left: 8,
      right: 8,
      bottom: 8,
      top: 15
    })
    .backgroundColor(Color.White)
  }

  @Styles
  pressedstyle(){
    .width('100%')
    .borderRadius(16)
    .padding({
      left: 8,
      right: 8,
      bottom: 8,
      top: 15
    })
    .backgroundColor(Color.White)
  }

  // 自定义标题栏
  @Builder
  customTitleBuilder() {
    Row() {
      Row({ space: 15 }) {
        Image($rawfile('Image/ic_cancel.png'))
          .height(20).width(20)
          .onClick(() => {
            this.pageStack.pop()
          })

        Text('新建闹钟')
          .fontSize(18)
          .fontColor(Color.Black)
          .fontWeight(FontWeight.Bold)
      }


      Image($rawfile('Image/ic_confirm.png'))
        .height(20).width(20)
        .onClick(async () => {
          const result: ReturnAlarmData = {
            hour: this.UserSelectHour,
            minute: this.UserSelectMinute,
            repeat: false,
            statutoryHoliday: false,
            alarmRingtone: $rawfile('audio/一帅到底.mp3'), // 默认铃声 | 注意：Resource 类型不能 JSON 序列化
            alarmClockName: "",
            AlarmDuration: 0,
            RepeatingInterval: [],
            isOpen:true,
            reminderId: await setAlarmReminder(Number(this.UserSelectHour), Number(this.UserSelectMinute)) // 添加代理提醒-获取闹钟Id
          }
          this.pageStack.pop(result)
        })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 15, right: 15 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    NavDestination() {
      TimePicker({ selected: this.selectedTime })
        .useMilitaryTime(true) // 设置24小时制
        .onChange((value: TimePickerResult) => {
          if (value.hour >= 0) {
            this.selectedTime.setHours(value.hour, value.minute)
            this.UserSelectHour = value.hour.toString()
            this.UserSelectMinute = value.minute.toString()
            console.info('select current date is: ' + JSON.stringify(value))
          }
        })
      // 时间选择器样式
      // .selectedTextStyle({ color: Color.Blue, font: { size: 24, weight: FontWeight.Normal } })
      // .disappearTextStyle({ color: Color.Red, font: { size: 15, weight: FontWeight.Lighter } })
      // .textStyle({ color: Color.Yellow, font: { size: 20, weight: FontWeight.Normal } })

      Scroll(this.scroller) {
        Column({ space: 10 }) {
          List({ space: 25 }) {
            ListItem() {
              Row() {
                Text('重复')
                  .fontSize(16)

                Row({ space: 3 }) {
                  Text('不重复')
                    .fontSize(14)
                    .fontColor('#666666')

                  SymbolGlyph($r('sys.symbol.chevron_right'))
                    .fontSize(20)
                    .fontColor(['#666666'])
                }
              }
              // .height(100)
              .width('100%')
              // .backgroundColor(Color.Red)
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .stateStyles({
              normal: {
                .backgroundColor(Color.Transparent)
              },
              pressed: {
                .backgroundColor('#e0e0e0')
              }
            })

            ListItem() {
              Row() {
                Text('法定工作日 （智能跳过节假日）')
                  .fontSize(16)

                Row() {
                  Toggle({ type: ToggleType.Switch, isOn: false }).id(`toggle_NewAlarmClock_${1}`)
                }
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .width('100%')

          }
          .divider({
            strokeWidth: 0.3, // 分割线宽度
            color: Color.Gray, // 分割线颜色
            startMargin: 0, // 分割线起始边距
            endMargin: 0
          })
          .ListStyle()

          List({ space: 25 }) {
            ListItem() {
              Row() {
                Text('闹钟铃声')
                  .fontSize(16)

                Row({ space: 3 }) {
                  Text('Flourish')
                    .fontSize(14)
                    .fontColor('#666666')

                  SymbolGlyph($r('sys.symbol.chevron_right'))
                    .fontSize(20)
                    .fontColor(['#666666'])
                }
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .width('100%')

            ListItem() {
              Row() {
                Text('闹钟名')
                  .fontSize(16)

                Row({ space: 3 }) {
                  Text(`闹钟`)
                    .fontSize(14)
                    .fontColor('#666666')

                  SymbolGlyph($r('sys.symbol.chevron_right'))
                    .fontSize(20)
                    .fontColor(['#666666'])
                }
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .width('100%')

            ListItem() {
              Row() {
                Text('闹钟时长')
                  .fontSize(16)

                Row({ space: 3 }) {
                  Text(`5分钟`)
                    .fontSize(14)
                    .fontColor('#666666')

                  SymbolGlyph($r('sys.symbol.chevron_right'))
                    .fontSize(20)
                    .fontColor(['#666666'])
                }
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .width('100%')

            ListItem() {
              Row() {
                Text('再响间隔')
                  .fontSize(16)

                Row({ space: 3 }) {
                  Text(`10分钟，3次`)
                    .fontSize(14)
                    .fontColor('#666666')

                  SymbolGlyph($r('sys.symbol.chevron_right'))
                    .fontSize(20)
                    .fontColor(['#666666'])
                }
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .width('100%')

          }
          .divider({
            strokeWidth: 0.3, // 分割线宽度
            color: Color.Gray, // 分割线颜色
            startMargin: 0, // 分割线起始边距
            endMargin: 0
          })
          .ListStyle()


          List({ space: 25 }) {
            ListItem() {
              Row() {
                Column({ space: 8 }) {
                  Text('语音简报')
                    .fontSize(16)
                    .width('100%')
                    .textAlign(TextAlign.Start)
                  Text('闹钟关闭，自动播报天气，日程、路况等')
                    .fontSize(13)
                    .width('100%')
                    .fontColor('#666666')
                }
                .width('70%')

                Row({ space: 3 }) {
                  SymbolGlyph($r('sys.symbol.chevron_right'))
                    .fontSize(20)
                    .fontColor(['#666666'])
                }

              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .width('100%')

          }
          .divider({
            strokeWidth: 0.3, // 分割线宽度
            color: Color.Gray, // 分割线颜色
            startMargin: 0, // 分割线起始边距
            endMargin: 0
          })
          .ListStyle()

        }
        .width('100%')
        .padding({ left: 13, right: 13 })
        .borderRadius(10)

        // .align(Alignment.Top) // 当子组件高度小于 Scroll 时，默认居中，可通过 `.align(Alignment.Top)` 调整
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring) // 滚动到边沿后回弹
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }

    .title(this.customTitleBuilder())
    .hideBackButton(true)
    .backgroundColor('#F2F3F5')

  }
}

export default NewAlarmClock