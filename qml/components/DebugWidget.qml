import Qt 4.7

Column {
    width: parent.width

    property string debugType: ""
    property variant debugContent: undefined


    Text {
        width: parent.width
        color: mytheme.colors.textColorOptions
        font.pixelSize: mytheme.font.sizeSettigs
        text: qsTr("Unknown %1 event!").arg(debugType)

        Image {
            anchors {
                right: parent.right
                rightMargin: 20
                top: parent.top
                topMargin: 20
            }
            source: "image://theme/icon-l-search"
            smooth: true
            sourceSize { width: 64; height: 64 }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    appWindow.sendDebugInfo(
                        {
                            "debugType": debugType,
                            "debugContent": debugContent
                        }
                    );
                }
            }
        }

    }

    Text {
        width: parent.width
        color: mytheme.colors.textColorOptions
        font.pixelSize: mytheme.font.sizeSigns
        text: qsTr("This event type is unknown.\nYou can help with resolution.")
    }
}
