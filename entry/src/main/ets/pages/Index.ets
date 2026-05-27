import AIarmList from './Main/AIarmList';
import ClockArea from './Main/ClockArea';
import NotificationUtil from './common/Notification/NotificationUtil';
import { setAlarmReminder } from './common/Notification/ReminderAgentUtil';
import { ReturnAlarmData } from './common/types/NewAlarmClock_Types';
import EditAlarmClock from './Detail/EditAlarmClock';
import NewAlarmClock from './Detail/NewAlarmClock';
import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import PreferencesUtil, {
  PreferencesUtil as PrefClass // PrefClass 是导入时的别名 因为命名冲突
} from '../pages/common/Preferences/PreferencesUtil';


@Entry
@Component
struct Index {
  @State title: string = '闹钟';
  @State NewAlarmClock_resultData: ReturnAlarmData[] = [];
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack();

  @Builder
  PageMap(name: string) { // 路由表
    if (name === 'NewAlarmClock') {
      NewAlarmClock()
    } else if (name === 'EditAlarmClock') {
      EditAlarmClock()
    }
  }

  aboutToAppear(): void {
    // 检查通知权限
    if (!NotificationUtil.isNotificationEnabled()) {
      NotificationUtil.requestNotificationPermission()
    }

    // 读取preferences配置
    let app_preferences = PreferencesUtil.get(PrefClass.STORE_NAME, PrefClass.defaultValue); // 当没键时，默认值是空数组
    this.NewAlarmClock_resultData = app_preferences as ReturnAlarmData[];
    console.log(`Index启动后 preferences配置:${JSON.stringify(app_preferences)}`);
  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        ClockArea()

        // Text('')
        //   .height('5%')

        // 装饰器	语法	  数据流向
        // @Prop	data: xxx	父 → 子（单向）
        // @Link	data: $xxx	父 ↔ 子（双向）
        // @Provide/@Consume	无需传递	祖先 ↔ 后代（跨层级）
        AIarmList({ NewAlarmClock_resultData: $NewAlarmClock_resultData })
      }
      .width('100%')
      .height('100%')
    }
    .title(this.title)
    .hideBackButton(true)
    .titleMode(NavigationTitleMode.Mini)
    .toolbarConfiguration(this.CustomToolbar)
    .navDestination(this.PageMap)
    .backgroundColor('#F1F4F6')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]) // 扩展安全区域
  }

  @Builder
  CustomToolbar() {
    Row() {
      Button() {
        Image('resources/rawfile/Image/ic_add.png')
          .width(40)
          .height(40)
          .objectFit(ImageFit.Contain)
      }
      .width(48)
      .height(48)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        if (!NotificationUtil.isNotificationEnabled()) {
          NotificationUtil.openNotificationSettings()
        } else {
          this.pageStack.pushPath({
            name: 'NewAlarmClock',
            // param: {},
            onPop: async (popInfo: PopInfo) => {
              // 接收子页面返回的结果
              console.log('新建闹钟页 返回的页面名:', popInfo.info.name)
              const result = popInfo.result as ReturnAlarmData

              // result.reminderId = await setAlarmReminder(Number(result.hour), Number(result.minute))
              // console.log(`闹钟Id:${result.reminderId}`)

              this.NewAlarmClock_resultData.push(result)
              // this.NewAlarmClock_resultData = [...this.NewAlarmClock_resultData, result] // 创建新数组，复制原数组所有元素 + 添加新项
              console.log('新建闹钟页 返回的内容', JSON.stringify(this.NewAlarmClock_resultData)) // 这是一个数组

              // 新建闹钟页面返回后 写入preferences
              PreferencesUtil.put(PrefClass.STORE_NAME, this.NewAlarmClock_resultData)
              console.log(`新建闹钟后 读取preferences：${JSON.stringify(PreferencesUtil.get(PrefClass.STORE_NAME,
                PrefClass.defaultValue))}`)
            }
          });
          console.info('Toolbar button clicked, pageStack:', JSON.stringify(this.pageStack));
        }
      })
    }
    .width('100%')
    .height(56) // Navigation的toolbar默认高度是56vp
    .justifyContent(FlexAlign.Center)
  }
}


