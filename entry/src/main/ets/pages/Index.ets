import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column({ space: 18 }) {
        Text('JSBridge 示例')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor('#0F172A')

        Text('点击下方按钮，进入 Web 页面查看 JSBridge 的同步、异步与回调交互演示。')
          .fontSize(15)
          .fontColor('#475569')
          .textAlign(TextAlign.Center)
          .lineHeight(24)
          .margin({ left: 8, right: 8 })

        Column({ space: 14 }) {
          Button() {
            Row({ space: 10 }) {
              Text('打开 Web 演示页')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor(Color.White)

              Text('>')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
            }
            .justifyContent(FlexAlign.Center)
            .width('100%')
          }
          .width('100%')
          .height(54)
          .borderRadius(18)
          .backgroundColor('#2563EB')
          .shadow({
            radius: 18,
            color: '#332563EB',
            offsetX: 0,
            offsetY: 10
          })
          .onClick(() => {
            router.push({
              url: 'pages/WebView'
            })
          })

          Text('建议在真机或模拟器中体验完整交互效果')
            .fontSize(13)
            .fontColor('#64748B')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .width('88%')
      .padding({
        left: 24,
        right: 24,
        top: 32,
        bottom: 32
      })
      .backgroundColor('#F8FAFC')
      .borderRadius(28)
      .shadow({
        radius: 24,
        color: '#1A0F172A',
        offsetX: 0,
        offsetY: 12
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EAF2FF')
    .linearGradient({
      angle: 135,
      colors: [['#F8FAFC', 0.0], ['#DBEAFE', 1.0]]
    })
  }
}
