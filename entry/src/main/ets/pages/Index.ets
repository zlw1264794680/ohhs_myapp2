// 卡片样式

@Styles
function card() {
  .width('100%')
  .backgroundColor('#fff')
  .padding(20)
  .shadow({
    color: '#ccc',
    radius: 10
  })
  .borderRadius(20)
}

@Extend(Text)
function h1() {
  .fontSize(20)
  .fontWeight(FontWeight.Bold)
}

interface TaskInter {
  name: string;
  finished: boolean;
}

class TaskDto implements TaskInter {
  id: string;
  name: string;
  finished: boolean;

  constructor(name: string) {
    this.id = `${Date.now().toString()}-${Math.random().toFixed(5).slice(2, 8)}`
    this.name = name
    this.finished = false
  }
}

@CustomDialog
struct CustomDialogExample {
  controller?: CustomDialogController
  @Link inputValue: string
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }
  build() {
    Column({ space: 20 }) {
      Text('添加任务').h1()
      TextInput({ text: this.inputValue, placeholder: '请输入任务名' }).width('100%').onChange((value: string) => {
        this.inputValue = value
      })
     Row(){
       Button('取消').onClick(()=>{
         if(this.controller){
           this.controller.close()
           this.cancel()
         }
       }).width(100).backgroundColor('#ffffff').fontColor('#333').border({
         width:1,
         color:'#ccc'
       })
       Button('确认').onClick(()=>{
         if(this.controller){
           this.controller.close()
           this.confirm()
         }
       }).width(100)
     }.width('100%').justifyContent(FlexAlign.SpaceEvenly).alignItems(VerticalAlign.Center)
    }.padding(20)
  }
}

@Entry
@Component
struct Index {
  @State @Watch('onTaskUpdated') taskList: Array<TaskDto> = [
    new TaskDto('任务1'),
    new TaskDto('任务2'),
    new TaskDto('任务3')
  ]
  @State taskFinish: number = 0
  @State taskTotal: number = 0

  // @Watch 回调
  onTaskUpdated(propName: string): void {
    console.log(propName)
    let taskFinish: number = 0
    this.taskList.forEach((item) => {
      if (item.finished) {
        taskFinish++;
      }
    })
    this.taskFinish = taskFinish
    this.taskTotal = this.taskList.length
  }

  onPageShow() {
    this.onTaskUpdated('taskList')
  }

  @Builder
  itemEnd(index: number) {
    Row() {
      Button('删除').margin(10).onClick(() => {
        this.taskList.splice(index, 1)
      })
    }.justifyContent(FlexAlign.SpaceEvenly)
  }

  // 添加任务名，输入框内容
  @State inputValue: string = ''
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomDialogExample({
      inputValue: $inputValue,
      confirm:()=>{ this.onAccept() },
      cancel:()=>{ this.onCancel() },
    }),
    cancel: this.exitApp,
    autoCancel: true,
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20 },
    gridCount: 4,
    customStyle: false,
    backgroundColor: 0xd9ffffff,
    cornerRadius: 10,
  })

  onCancel() {
    console.info('Callback when the first button is clicked')
  }

  onAccept() {
    console.info('Callback when the second button is clicked')
    if(this.inputValue){
      this.taskList.push(new TaskDto(this.inputValue))
    }
  }

  exitApp() {
    console.info('Click the callback in the blank area')
  }

  build() {
    Scroll() {
      Column({ space: 20 }) {
        // 任务统计
        Row() {
          Row() {
            Text('任务统计').h1()
            Stack() {
              Progress({
                value: this.taskFinish,
                total: this.taskTotal,
                type: ProgressType.Ring
              })
              Text(`${this.taskFinish} / ${this.taskTotal}`)
            }
          }.alignItems(VerticalAlign.Center).justifyContent(FlexAlign.SpaceEvenly).card()
        }.padding(20)

        // 添加
        Button('添加任务').width('calc(100% - 40vp)').onClick(() => {
          if(this.dialogController){
            this.dialogController.open()
          }
        })
        //  列表
        List({ space: 16 }) {
          ForEach(this.taskList, (item: TaskDto, index: number) => {
            ListItem() {
              Row() {
                Text(item.name).fontSize(16)
                Checkbox({ name: item.id, group: 'taskGroup' })
                  .select(item.finished)
                  .selectedColor(0xed6f21)
                  .onChange((value: boolean) => {
                    item.finished = value
                    this.taskList.splice(index, 1, item)
                  })
              }.card().justifyContent(FlexAlign.SpaceBetween)
            }
            .margin({
              left: 20,
              right: 20,
              top: 2,
              bottom: 2
            })
            .swipeAction({
              end: {
                builder: () => {
                  this.itemEnd(index)
                },
              }
            })
          })
        }
        .scrollBar(BarState.Off).layoutWeight(1).padding({
          top: 2,
          bottom: 10
        })
      }
    }
  }
}