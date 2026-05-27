import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import NotificationUtil from '../pages/common/Notification/NotificationUtil';
import PreferencesUtil from '../pages/common/Preferences/PreferencesUtil';
// 导入方式	  导入的是什么	          能否直接调用 init()
// import   { PreferencesUtil }	类	❌ 需要先 getInstance()
// import   PreferencesUtil	实例对象	✅ 可以直接调用

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

    /*
    这里的 this.context 是 UIAbilityContext 代表整个应用的能力上下文
    特点：
    在应用启动时创建
    整个应用生命周期内存在
    可以调用系统能力（启动应用、获取资源等）*/
    NotificationUtil.initialize(this.context);
    /*┌─────────────────────────────────────────────────────────────┐
    │                        应用架构                              │
    │                                                             │
    │  ┌─────────────────────────────────────────────────────┐   │
    │  │  EntryAbility（应用入口）                             │   │
    │  │  this.context = UIAbilityContext                     │   │
    │  │  代表整个应用的能力上下文                              │   │
    │  └─────────────────────────────────────────────────────┘   │
    │                          │                                  │
    │                          ↓                                  │
    │  ┌─────────────────────────────────────────────────────┐   │
    │  │  页面 Index.ets                                       │   │
    │  │  getContext(this) = UIContext                        │   │
    │  │  代表当前页面的 UI 上下文                              │   │
    │  └─────────────────────────────────────────────────────┘   │
    └─────────────────────────────────────────────────────────────┘
    */

  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });


    PreferencesUtil.init(this.context);
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}