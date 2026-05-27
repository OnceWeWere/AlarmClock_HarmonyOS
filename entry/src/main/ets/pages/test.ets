@Entry
@Component
@Preview
struct NestedScrollExample {
  private scrollerForScroll: Scroller = new Scroller()
  private scrollerForList: Scroller = new Scroller()
  private arr: number[] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

  build() {
    Scroll(this.scrollerForScroll) {
      Column() {
        // 顶部区域
        Text("Header Area")
          .width("100%")
          .height(200)
          .backgroundColor(Color.Blue)

        // 嵌套List
        List({ space: 20, scroller: this.scrollerForList }) {
          ForEach(this.arr, (item: number) => {
            ListItem() {
              Text("ListItem " + item)
                .width("100%")
                .height(100)
                .backgroundColor(Color.White)
                .borderRadius(15)
            }
          }, (item: number) => item.toString())
        }
        .width("100%")
        .height(300)
        .edgeEffect(EdgeEffect.None)
        .nestedScroll({
          scrollForward: NestedScrollMode.PARENT_FIRST,
          scrollBackward: NestedScrollMode.SELF_FIRST
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}