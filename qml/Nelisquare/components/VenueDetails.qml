import Qt 4.7

Rectangle {
    id: place
    signal checkin()
    signal markToDo()
    signal showAddTip()
    signal user(string user)
    signal photo(string photo)
    width: parent.width
    color: "#eee"

    property string venueID: ""
    property string venueName: ""
    property string venueAddress: ""
    property string venueCity: ""
    property string venueMajor: ""
    property string venueMajorID: ""
    property string venueMajorPhoto: ""
    property string venueHereNow: ""
    property string venueCheckinsCount: ""
    property string venueUsersCount: ""

    property alias tipsModel: tipsModel
    property alias photosBox: photosBox
    property alias usersBox: usersBox

    ListModel {
        id: tipsModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    Column {
        anchors.fill: parent

        Rectangle {
            z: 100
            width: parent.width
            height: 140
            color: theme.toolbarLightColor

            Text {
                id: venueNameText
                text: place.venueName
                font.pixelSize: 24
                font.bold: true
                color: "#fff"
                x: 10
                y: 10
            }

            Text {
                id: venueAddressText
                text: place.venueAddress
                font.pixelSize: 20
                color: "#fff"
                x: 10
                y: venueNameText.y + venueNameText.height
            }

            GreenButton {
                label: "CHECK IN HERE"
                width: parent.width - 20
                x: 10
                y: venueAddressText.y + venueAddressText.height + 8

                onClicked: {
                    place.checkin();
                }
            }

        }

        Rectangle {
            z:100
            width: parent.width
            height: 10
            color: "#A8CB17"

            Rectangle {
                width: parent.width
                height: 1
                color: "#A8CB17"
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#888"
                y: 9
            }
        }

        Flickable {
            id: flickableArea
            width: parent.width
            contentWidth: parent.width
            height: 500//place.height - y

            clip: true
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds
            pressDelay: 100

            Column {
                onHeightChanged: {
                    flickableArea.contentHeight = height;
                }

                width: parent.width - 20
                x: 10
                spacing: 10

                Text {
                    text: place.venueMajor.length>0 ? place.venueMajor : "Venue doesn't have mayor yet!"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#111"
                }

                Text {
                    text: place.venueMajor.length>0 ? "is the mayor." : "It could be you!"
                    font.pixelSize: 20
                    color: "#888"
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#ccc"
                }

                PhotosBox {
                    id: photosBox
                    onItemSelected: {
                        place.photo(object);
                    }
                }

                PhotosBox {
                    id: usersBox
                    showButtons: false
                    photoSize: 64
                    onItemSelected: {
                        place.user(object)
                    }
                }

                Text {
                    width: parent.width
                    text: "User tips:"
                    visible: tipsModel.count>0
                }
                Repeater {
                    id: tipRepeater
                    width: parent.width
                    model: tipsModel
                    delegate: tipDelegate
                    visible: tipsModel.count>0
                }
                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#ccc"
                    visible: tipsModel.count>0
                }
                Row {
                    width: parent.width
                    height: 50
                    spacing: 10
                    BlueButton {
                        label: "Add tip"
                        width: parent.width / 2 - 5
                        onClicked: {
                            place.showAddTip();
                        }
                    }
                    BlueButton {
                        label: "Mark to-do"
                        width: parent.width / 2 - 5
                        onClicked: {
                            place.markToDo();
                        }
                    }
                }
                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#ccc"
                    visible: tipsModel.count>0
                }
            }
            ProfilePhoto {
                id: profileImage
                x: parent.width - 75
                photoUrl: place.venueMajorPhoto
                visible: place.venueMajor.length>0

                onClicked: {
                    place.user(venueMajorID);
                }
            }
        }
    }

    Component {
        id: tipDelegate

        EventBox {
            width: tipRepeater.width

            userShout: model.tipText
            createdAt: model.tipAge
            fontSize: 18

            Component.onCompleted: {
                userPhoto.photoUrl = model.userPhoto
                userPhoto.photoSize = 48
                userPhoto.photoBorder = 2
            }
            onUserClicked: {
                place.user(model.userID);
            }
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: place
                x: parent.width
            }
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: place
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: place
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            SequentialAnimation {
                PropertyAnimation {
                    target: place
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}