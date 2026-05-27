import { window } from "@kit.ArkUI";

@Preview
@Component
struct ClockArea {
  // 用来配置CanvasRenderingContext2D对象的参数，包括是否开启抗锯齿，true表明开启抗锯齿。
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  // 用来创建CanvasRenderingContext2D对象，通过在canvas中调用CanvasRenderingContext2D对象来绘制。
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  @State windowWidth: number = 0;
  @State windowHeight: number = 0;
  @State @Watch('canvasSize_Change') canvasSize: number = 0;
  @State clockRadius: number = 124 // 表盘半径

  aboutToAppear(): void {
    // 获取屏幕窗口尺寸
    this.getWindowsSize()
  }

  build() {
    if (this.canvasSize > 0) {
      Canvas(this.context) {
      }
      .width(this.canvasSize)
      .aspectRatio(1)
      .onReady(() => {
        this.StartDrawTask()
      })
    }
  }

  async getWindowsSize() {
    try {
      const windowClass = await window.getLastWindow(getContext(this)); // 获取窗口实例
      const properties = windowClass.getWindowProperties(); // 获取窗口属性对象
      const rect = properties.windowRect; // 窗口矩形区域，包含宽高和位置

      this.windowWidth = rect.width; // 单位：px
      this.windowHeight = rect.height; // 单位：px

      // 根据窗口宽度设置画布大小（取较小边的70%）
      this.canvasSize = px2vp(Math.min(rect.width, rect.height) * 0.7);
      // this.canvasSize = Math.min(rect.width, rect.height) * 0.7;
      console.log(`窗口宽度: ${rect.width}, 高度: ${rect.height}, 画布大小: ${this.canvasSize}`);
    } catch (exception) {
      console.error('获取窗口属性失败: ' + JSON.stringify(exception));
    }
  }

  canvasSize_Change(changedPropertyName: string) {
    this.clockRadius = this.canvasSize / 2 - 2;
    console.log(`canvasSize:${this.canvasSize},clockRadius:${this.clockRadius}`)
  }

  StartDrawTask() {
    // 坐标点移动到画布中心
    this.context.translate(this.canvasSize / 2, this.canvasSize / 2)
    this.DrawClockArea()
    setInterval(() => {
      this.DrawClockArea()
    }, 1000)
  }

  // 表盘
  DrawPan() {
    // 以坐标为圆心，让图片展开
    this.context.beginPath()
    let imgWidth = this.clockRadius * 2
    let ImgBitmap = new ImageBitmap('resources/rawfile/Image/ic_clock_pan.png')
    this.context.drawImage(ImgBitmap, -this.clockRadius, -this.clockRadius, imgWidth, imgWidth)
  }

  // 指针
  DrawHourPointer(degree: number, pointerImg: string) {
    this.context.save()
    let angle = (degree + 180) * Math.PI / 180

    this.context.rotate(angle)
    this.context.beginPath()
    let ImgBitmap = new ImageBitmap(pointerImg)
    let imgWidth = 10
    this.context.drawImage(ImgBitmap, -imgWidth / 2, -this.clockRadius, imgWidth, this.clockRadius * 2)
    this.context.restore()
  }

  DrawMinutePointer(degree: number, pointerImg: string) {
    this.context.save()
    let angle = (degree + 180) * Math.PI / 180
    this.context.rotate(angle)
    this.context.beginPath()
    let ImgBitmap = new ImageBitmap(pointerImg)
    let imgWidth = 10
    this.context.drawImage(ImgBitmap, -imgWidth / 2, -this.clockRadius, imgWidth, this.clockRadius * 2)
    this.context.restore()
  }

  DrawSecondPointer(degree: number, pointerImg: string) {
    this.context.save()
    let angle = (degree + 180) * Math.PI / 180
    this.context.rotate(angle)
    this.context.beginPath()
    let ImgBitmap = new ImageBitmap(pointerImg)
    let imgWidth = 10
    this.context.drawImage(ImgBitmap, -imgWidth / 2, -this.clockRadius, imgWidth, this.clockRadius * 2)
    this.context.restore()
  }

  DrawClockArea() {
    // 删除画布上指定矩形区域内的所有像素，使其变为透明。
    this.context.clearRect(-this.canvasSize, -this.canvasSize, this.canvasSize * 2, this.canvasSize * 2)

    // 获取系统时间
    let date = new Date()
    let hours = date.getHours()
    let minutes = date.getMinutes()
    let seconds = date.getSeconds()

    this.DrawPan()
    this.DrawHourPointer(30 * (hours >= 12 ? hours - 12 : hours) + 0.5 * minutes, // 每小时30度 ÷ 60分钟 = 0.5度/分钟
      'resources/rawfile/Image/ic_hour_pointer.png')
    this.DrawMinutePointer(6 * minutes,
      'resources/rawfile/Image/ic_minute_pointer.png')
    this.DrawSecondPointer(6 * seconds,
      'resources/rawfile/Image/ic_second_pointer.png')
  }
}


export default ClockArea



