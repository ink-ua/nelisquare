import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

//Sheet {
PageWrapper {
    id: checkin
    //width: parent.width
    //height: items.height + 20
    //color: mytheme.colors.backgroundBlueDark
    state: "hidden"
    property string venueID: ""
    property string venueName: ""
    property bool useFacebook: configuration.shareCheckinFacebook === "1"
    property bool useTwitter: configuration.shareCheckinTwitter === "1"
    property bool useFriends: configuration.shareCheckinFriends === "1"

    signal userSelected(string userId, string userName)
    signal checkin(string venueID, string comment, bool friends, bool facebook, bool twitter)

    headerText: qsTr("NEW CHECK-IN")
    headerIcon: "../icons/icon-header-newcheckin.png"
    headerBubble: false

    function reset() {
        shoutText.text = "";
    }

    function checkinCompleted(checkinID, message, specials) {
        waiting_hide();
        show_info(message);
        stack.replace(Qt.resolvedUrl("../pages/Checkin.qml"),{"checkinID":checkinID , "specials": specials});
    }

    onUserSelected: {
        stack.pop()

        var cursorPos = shoutText.cursorPosition
        shoutText.text = shoutText.text.substring(0, cursorPos) +
                "/" + userId + "/" + userName + "/" +
                shoutText.text.substring(cursorPos, shoutText.text.length)

        //mentionedModel.append({ "id": userId, "name": userName })
    }
    onCheckin: {
        waiting_show();
        var mentions = []
        var pattern = /\/(.+?)\/(.+?)\//gm
        var commentText = comment.replace(pattern, function(match, pId, pName, offset, str) {
            mentions.push([ offset, offset + pName.length, pId ].join(","))
            var result = pName // str.substring(0, offset) + pName + str.substring(offset + match.length, str.length)
            console.log("result " + result)
            return result
        })
        console.log("checkin " + commentText)
        console.log("mentinos " + mentions.join(";"))
        Api.checkin.addCheckin(venueID, checkin, commentText, friends, facebook, twitter, mentions.join(";"));
    }
    tools: ToolBarLayout{
        parent: checkin
        //anchors.centerIn: parent;
        anchors{ left: parent.left; right: parent.right; margins: mytheme.graphicSizeLarge }
        ButtonRow{
            exclusive: false
            spacing: mytheme.graphicSizeTiny
            ToolButton {
                text: qsTr("CHECK IN")
                platformStyle: SheetButtonAccentStyle { }
                onClicked: {
                    enabled = false;
                    checkin.checkin( checkin.venueID, shoutText.text, checkin.useFriends, checkin.useFacebook, checkin.useTwitter )

                }
            }
            ToolButton {
                text: qsTr("Cancel")
                onClicked: stack.pop();
            }
        }
    }

    Flickable{
        id: flickableArea
        anchors.top: pagetop
        width: parent.width
        height: parent.height - y
        contentWidth: parent.width

        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: 100

        Column {
            onHeightChanged: {
                flickableArea.contentHeight = height + y;
            }

            id: items
            x: 10
            y: 10
            width: parent.width - 20
            spacing: 10

            Text {
                id: venueName
                text: checkin.venueName
                width: parent.width
                font.pixelSize: 24
                color: mytheme.colors.textColorOptions
            }

            TextArea {
                id: shoutText
                x: 5
                width: parent.width - 10
                height: 130

                placeholderText: qsTr("Whats on your mind?")
                textFormat: TextEdit.PlainText

                font.pixelSize: mytheme.fontSizeMedium

                onTextChanged: {
                    if (text.length>140) {
                        errorHighlight = true;
                    } else {
                        errorHighlight = false;
                        // shoutTextLen.text = 140 - text.length
                    }
                }
                Text {
                    id: shoutTextLen
                    anchors {
                        right: parent.right;
                        bottom: parent.bottom;
                        bottomMargin: mytheme.paddingMedium;
                        rightMargin: mytheme.paddingXLarge
                    }
                    font.pixelSize: mytheme.fontSizeMedium
                    color: mytheme.colors.textColorTimestamp
                    text: 140 - shoutText.text.length //'140'
                }
            }

            Column {
                width: parent.width

                SectionHeader {
                    text: qsTr("Mention friends")
                }

                ListModel {
                    id: mentionedModel
                }
                ListView {
                    id: mentionedList
                    model: mentionedModel
                    width: parent.width
                    height: count * 30
                    delegate: mentionedDelegate
                    interactive: false
                }
                ScrollDecorator{ flickableItem: mentionedList }
                Component {
                    id: mentionedDelegate

                    Item {
                        width: parent.width
                        Text {
                            id: name
                            font.pixelSize: mytheme.fontSizeLarge
                            color: mytheme.colors.textColorOptions
                            anchors.verticalCenter: remove.verticalCenter
                            anchors.left: parent.left
                            anchors.margins: mytheme.paddingMedium
                            text: model.name
                        }
                        //Item {
                        //    id: id
                        //    data: model.id
                        //}
                        Button {
                            id: remove
                            anchors.right: parent.right
                            anchors.margins: mytheme.paddingMedium
                            width: height
                            iconSource: "image://theme/icon-s-cancel"
                            onClicked: mentionedModel.remove(mentionedList.currentIndex)
                        }
                    }
                }

                Button {
                    id: mentionFriend
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 130
                    text: qsTr("Add friend")
                    onClicked: {
                        stack.push(Qt.resolvedUrl("UsersList.qml"),{"objType":"user","objID":"self","selectUserAction":checkin});
                    }
                }
            }

            Column {
                width: parent.width

                SectionHeader {
                    text: qsTr("Sharing options")
                }

                SettingSwitch {
                    text: qsTr("Share with Friends")
                    checked: checkin.useFriends
                    onCheckedChanged: {
                        configuration.shareCheckinFriends = (checked) ? "1": "0"
                    }
                }

                SettingSwitch {
                    text: qsTr("Post to Facebook")
                    checked: checkin.useFacebook
                    onCheckedChanged: {
                        configuration.shareCheckinFacebook = (checked) ? "1": "0"
                    }
                }

                SettingSwitch {
                    text: qsTr("Post to Twitter")
                    checked: checkin.useTwitter
                    onCheckedChanged: {
                        configuration.shareCheckinTwitter = (checked) ? "1": "0"
                    }
                }
            }
        }
    }
}
