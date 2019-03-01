import QtQuick 2.2
import Felgo 3.0

EntityBase{
  id: tile
  entityType: "Tile"

  width: gridWidth / gridSizeGame
  height: width

  property int tileIndex
  property int tileValue
  property color tileColor
  property color tileTextColor: "white"
  property string tileText


  property int tileFontSize: width/3


  property int animationDuration: system.desktopPlatform ? 500 : 250


  property var bgColors: ["#000000", "#FFFF00 ", "#00EE76", "#FF0000", "#FFFF00", "#00FFFF", "#FFDEAD", "#FF1493", "#EEDC82", "#1C15B6", "#E8E8E8", "#EE3A8C"]


  Rectangle {
    id: innerRect
    anchors.centerIn: parent
    width: parent.width-2
    height: width
    radius: 4
    color: bgColors[tileValue]


    Text {
      id: innerRectText
      anchors.centerIn: parent
      color: tileTextColor
      font.pixelSize: tileFontSize
      text: Math.pow(2, tileValue)
    }
  }


  Component.onCompleted: {
    x = (width) * (tileIndex % gridSizeGame)
    y = (height) * Math.floor(tileIndex/gridSizeGame)
    tileValue = Math.random() < 0.9 ? 1 : 2
    showTileAnim.start()
  }


  function moveTile(newTileIndex) {
    tileIndex = newTileIndex
    moveTileAnim.targetPoint.x = ((width) * (tileIndex % gridSizeGame))
    moveTileAnim.targetPoint.y = ((height) * Math.floor(tileIndex/gridSizeGame))
    moveTileAnim.start()
  }

  function destroyTile() {
    deathAnimation.start()
  }


  ParallelAnimation {
    id: showTileAnim


    NumberAnimation {
      target: innerRect
      property: "opacity"
      from: 0.0
      to: 1.0
      duration: animationDuration
    }


    ScaleAnimator {
      target: innerRect
      from: 0
      to: 1
      duration: animationDuration
      easing.type: Easing.OutQuad
    }
  }


  ParallelAnimation {
    id: moveTileAnim
    property point targetPoint: Qt.point(0,0)
    NumberAnimation {
      target: tile
      property: "x"
      duration: animationDuration/2
      to: moveTileAnim.targetPoint.x
    }
    NumberAnimation {
      target: tile
      property: "y"
      duration: animationDuration/2
      to: moveTileAnim.targetPoint.y
    }
  }


  SequentialAnimation {
    id: deathAnimation
    NumberAnimation {
      target: innerRect
      property: "opacity"
      from: 1
      to: 0
      duration: animationDuration/2
    }
    ScriptAction {
      script: removeEntity()
    }
  }
}
