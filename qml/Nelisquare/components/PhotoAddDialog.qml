import Qt 4.7
import QtMobility.gallery 1.1

Rectangle {
    signal path(string checkin, string photo)

    property string checkinID: ""

    id: photoAddDialog
    width: parent.width
    height: parent.height

    ListModel {
        id: emptyModel
    }

    DocumentGalleryModel {
        id: galleryModel

        autoUpdate: true
        scope: DocumentGallery.Image  //real
        properties: [ "filePath" ]    //real
        //rootType: DocumentGallery.Image //Sim
        //properties: [ "fileName" ]      //Sim
        filter: GalleryWildcardFilter {
            property: "fileName";
            value: "*.jpg";
        }
        sortProperties: [ "-lastModified" ]
    }

    Component {
         id: photoDelegate
         ProfilePhoto {
            photoUrl: model.filePath      //real
            //photoUrl: model.fileName        //sim
            photoSize: photoGrid.cellWidth
            photoSourceSize: photoGrid.cellWidth
            photoBorder: 2
            photoSmooth: false
            photoAspect: Image.PreserveAspectFit
            onClicked: {
                photoAddDialog.path(checkinID, model.filePath);
            }
         }
     }

    GridView {
        id: photoGrid
        width: parent.width
        height: parent.height
        cellWidth: Math.min((width-5)/3,height)
        cellHeight: cellWidth
        clip: true
        model: emptyModel
        delegate: photoDelegate
        header: Text {
            text: "Select photo for upload"
        }
    }

    onStateChanged: {
        if (state == "shown") {
            photoGrid.model = galleryModel;
        } else {
            photoGrid.model = emptyModel;
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: photoAddDialog
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: photoAddDialog
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            SequentialAnimation {
                PropertyAnimation {
                    target: photoAddDialog
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}
