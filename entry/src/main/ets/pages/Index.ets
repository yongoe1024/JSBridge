import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Column() {
      Button('').onClick((event: ClickEvent) => {
        router.push({
          url: "pages/WebView"
        })

      })
    }
  }
}