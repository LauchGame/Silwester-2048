import Felgo 3.0
 import QtQuick 2.2

 GameWindow {
   id: gameWindow

   screenWidth: 960
   screenHeight: 640

   property int gridWidth: 300
    property int gridSizeGame: 6
    property int gridSizeGameSquared: gridSizeGame*gridSizeGame
    property var emptyCells
    property var tileItems:  new Array(gridSizeGameSquared)
   EntityManager {
       id: entityManager
       entityContainer: gameContainer
     }


   Scene {
     id: gameScene

     width: 480
     height: 320
     Component.onCompleted: {

           for(var i = 0; i < gridSizeGameSquared; i++)
             tileItems[i] = null


           updateEmptyCells()


           createNewTile()
           createNewTile()
         }

     Rectangle {
           id: background
           anchors.fill: gameScene.gameWindowAnchorItem
           color: "#F0FFF0"
           border.width: 5
           border.color: "#000000"
           radius: 10
           Keys.forwardTo: keyboardController

               }

     Item {
           id: gameContainer
           width: gridWidth
           height: width
           anchors.centerIn: parent

           GameHintergrund {}
         }
     Timer {
           id: moveRelease
           interval: 300
         }
     Item {
           id: keyboardController

           Keys.onPressed: {
             if(!system.desktopPlatform)
               return

             if (event.key === Qt.Key_Left && moveRelease.running === false) {
               event.accepted = true
               moveLeft()
               moveRelease.start()
               console.log("move Left")
             }
             else if (event.key === Qt.Key_Right && moveRelease.running === false) {
               event.accepted = true
               moveRight()
               moveRelease.start()
               console.log("move Right")
             }
             else if (event.key === Qt.Key_Up && moveRelease.running === false) {
               event.accepted = true
               moveUp()
               moveRelease.start()
               console.log("move Up")
             }
             else if (event.key === Qt.Key_Down && moveRelease.running === false) {
               event.accepted = true
               moveDown()
               moveRelease.start()
               console.log("move Down")
             }
           }
         }


     MouseArea {
           id:mouseArea
           anchors.fill: gameScene.gameWindowAnchorItem

           property int startX
           property int startY
           property string direction
           property bool moving: false


           onPressed: {
             startX = mouse.x
             startY = mouse.y
             moving = false
           }

           onReleased: {
             moving = false
           }

           onPositionChanged: {
             var deltax = mouse.x - startX
             var deltay = mouse.y - startY

             if (moving === false) {
               if (Math.abs(deltax) > 40 || Math.abs(deltay) > 40) {
                 moving = true

                 if (deltax > 30 && Math.abs(deltay) < 30 && moveRelease.running === false) {
                   console.log("move Right")
                   moveRight()
                   moveRelease.start()
                 }
                 else if (deltax < -30 && Math.abs(deltay) < 30 && moveRelease.running === false) {
                   console.log("move Left")
                   moveLeft()
                   moveRelease.start()
                 }
                 else if (Math.abs(deltax) < 30 && deltay > 30 && moveRelease.running === false) {
                   console.log("move Down")
                   moveDown()
                   moveRelease.start()
                 }
                 else if (Math.abs(deltax) < 30 && deltay < 30 && moveRelease.running === false) {
                   console.log("move Up")
                   moveUp()
                   moveRelease.start()
                 }
               }
             }
           }
         }

       }
   function updateEmptyCells() {
     emptyCells = []
     for (var i = 0; i < gridSizeGameSquared; i++) {
       if(tileItems[i] === null)
         emptyCells.push(i)
     }
   }


   function createNewTile() {
     var randomCellId = emptyCells[Math.floor(Math.random() * emptyCells.length)]
     var tileId = entityManager.createEntityFromUrlWithProperties(Qt.resolvedUrl("Tile.qml"), {"tileIndex": randomCellId})
     tileItems[randomCellId] = entityManager.getEntityById(tileId)
     emptyCells.splice(emptyCells.indexOf(randomCellId), 1)
   }
   function merge(soureRow) {
      var i, j
      var nonEmptyTiles = []
      var indices = []


      for(i = 0; i < soureRow.length; i++) {
        indices[i] = nonEmptyTiles.length
        if(soureRow[i] > 0)
          nonEmptyTiles.push(soureRow[i])
      }

      var mergedRow = []

      for(i = 0; i < nonEmptyTiles.length; i++) {

        if(i === nonEmptyTiles.length - 1)
          mergedRow.push(nonEmptyTiles[i])
        else {

          if (nonEmptyTiles[i] === nonEmptyTiles[i+1]) {
            for(j = 0; j < soureRow.length; j++) {
              if(indices[j] > mergedRow.length)
                indices[j] -= 1
            }


            mergedRow.push(nonEmptyTiles[i] + 1)
            i++
          }
          else {

            mergedRow.push(nonEmptyTiles[i])
          }
        }
      }


      for( i = mergedRow.length; i < soureRow.length; i++)
        mergedRow[i] = 0


      return {mergedRow : mergedRow, indices: indices}
    }
   function getRowAt(index) {
       var row  = []
       for(var j = 0; j < gridSizeGame; j++) {

         if(tileItems[j + index * gridSizeGame] === null)
           row.push(0)
         else
           row.push(tileItems[j + index * gridSizeGame].tileValue)
       }

       return row
     }
   function moveLeft() {
      var isMoved = false
      var sourceRow, mergedRow, merger, indices
      var i, j

      for(i = 0; i < gridSizeGame; i++) {
        sourceRow = getRowAt(i)
        merger = merge(sourceRow)
        mergedRow = merger.mergedRow
        indices = merger.indices


        if (!arraysIdentical(sourceRow, mergedRow)) {
          isMoved = true

          for(j = 0; j < sourceRow.length; j++) {

            if (sourceRow[j] > 0 && indices[j] !== j) {

              if (mergedRow[indices[j]] > sourceRow[j] && tileItems[gridSizeGame * i + indices[j]] !== null) {

                tileItems[gridSizeGame * i + indices[j]].tileValue++
                tileItems[gridSizeGame * i + j].moveTile(gridSizeGame * i + indices[j])
                tileItems[gridSizeGame * i + j].destroyTile()
              } else {

                tileItems[gridSizeGame * i + j].moveTile(gridSizeGame * i + indices[j])
                tileItems[gridSizeGame * i + indices[j]] = tileItems[gridSizeGame * i + j]
              }
              tileItems[gridSizeGame * i + j] = null
            }
          }
        }
      }

      if (isMoved) {

        updateEmptyCells()

        createNewTile()
      }
     }

   function moveRight() {
      var isMoved = false
      var sourceRow, mergedRow, merger, indices
      var i, j, k

      for(i = 0; i < gridSizeGame; i++) {

        sourceRow = getRowAt(i).reverse()
        merger = merge(sourceRow)
        mergedRow = merger.mergedRow
        indices = merger.indices

        if (!arraysIdentical(sourceRow,mergedRow)) {
          isMoved = true

          sourceRow.reverse()
          mergedRow.reverse()
          indices.reverse()

          for (j = 0; j < indices.length; j++)
            indices[j] = gridSizeGame - 1 - indices[j]

          for(j = 0; j < sourceRow.length; j++) {
            k = sourceRow.length -1 - j

            if (sourceRow[k] > 0 && indices[k] !== k) {
              if (mergedRow[indices[k]] > sourceRow[k] && tileItems[gridSizeGame * i + indices[k]] !== null) {

                tileItems[gridSizeGame * i + indices[k]].tileValue++
                tileItems[gridSizeGame * i + k].moveTile(gridSizeGame * i + indices[k])
                tileItems[gridSizeGame * i + k].destroyTile()
              } else {

                tileItems[gridSizeGame * i + k].moveTile(gridSizeGame * i + indices[k])
                tileItems[gridSizeGame * i + indices[k]] = tileItems[gridSizeGame * i + k]
              }
              tileItems[gridSizeGame * i + k] = null
            }
          }
        }
      }

      if (isMoved) {

        updateEmptyCells()

        createNewTile()
      }
    }
    function getColumnAt(index) {
          var column = []
          for(var j = 0; j < gridSizeGame; j++) {

            if(tileItems[index + j * gridSizeGame] === null)
              column.push(0)
            else
              column.push(tileItems[index + j * gridSizeGame].tileValue)

          }
          return column
        }

        function arraysIdentical(a, b) {
          var i = a.length
          if (i !== b.length) return false
          while (i--) {
            if (a[i] !== b[i]) return false
          }
          return true
        }
        function moveUp() {
          var isMoved = false
          var sourceRow, mergedRow, merger, indices
          var i, j

          for (i = 0; i < gridSizeGame; i++) {
            sourceRow = getColumnAt(i)
            merger = merge(sourceRow)
            mergedRow = merger.mergedRow
            indices = merger.indices

            if (! arraysIdentical(sourceRow,mergedRow)) {
              isMoved = true
              for (j = 0; j < sourceRow.length; j++) {
                if (sourceRow[j] > 0 && indices[j] !== j) {

                  if (mergedRow[indices[j]] > sourceRow[j] && tileItems[gridSizeGame * indices[j] + i] !== null) {

                    tileItems[gridSizeGame * indices[j] + i].tileValue++
                    tileItems[gridSizeGame * j + i].moveTile(gridSizeGame * indices[j] + i)
                    tileItems[gridSizeGame * j + i].destroyTile()
                  } else {

                    tileItems[gridSizeGame * j + i].moveTile(gridSizeGame * indices[j] + i)
                    tileItems[gridSizeGame * indices[j] + i] = tileItems[gridSizeGame * j + i]
                  }
                  tileItems[gridSizeGame * j + i] = null
                }
              }
            }
          }

          if (isMoved) {

            updateEmptyCells()

            createNewTile()
          }
        }
        function moveDown() {
            var isMoved = false
            var sourceRow, mergedRow, merger, indices
            var j, k

            for (var i = 0; i < gridSizeGame; i++) {
              sourceRow = getColumnAt(i).reverse()
              merger = merge(sourceRow)
              mergedRow = merger.mergedRow
              indices = merger.indices

              if (! arraysIdentical(sourceRow,mergedRow)) {
                isMoved = true
                sourceRow.reverse()
                mergedRow.reverse()
                indices.reverse()

                for (j = 0; j < gridSizeGame; j++)
                  indices[j] = gridSizeGame - 1 - indices[j]

                for (j = 0; j < sourceRow.length; j++) {
                  k = sourceRow.length -1 - j

                  if (sourceRow[k] > 0 && indices[k] !== k) {

                    if (mergedRow[indices[k]] > sourceRow[k] && tileItems[gridSizeGame * indices[k] + i] !== null) {

                      tileItems[gridSizeGame * indices[k] + i].tileValue++
                      tileItems[gridSizeGame * k + i].moveTile(gridSizeGame * indices[k] + i)
                      tileItems[gridSizeGame * k + i].destroyTile()

                    } else {

                      tileItems[gridSizeGame * k + i].moveTile(gridSizeGame * indices[k] + i)
                      tileItems[gridSizeGame * indices[k] + i] = tileItems[gridSizeGame * k + i]
                    }
                    tileItems[gridSizeGame * k + i] = null
                  }
                }
              }
            }

            if (isMoved) {

              updateEmptyCells()

              createNewTile()
            }
          }




 }











