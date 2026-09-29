// ══════════════════════════════════════════════════════════════
//  FINAL FANTASY XIV — SDDM Login Theme  (MP4 + PNG support)
//  Save folder to: /usr/share/sddm/themes/ffxiv-login/
//  Put your video:  /usr/share/sddm/themes/ffxiv-login/background.mp4
//  Put your sound:  /usr/share/sddm/themes/ffxiv-login/login.mp3
//  Put your logo:   /usr/share/sddm/themes/ffxiv-login/logo.png
// ══════════════════════════════════════════════════════════════

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtMultimedia 5.15
import SddmComponents 2.0

Rectangle {
    id: root
    width:  Screen.width
    height: Screen.height
    color:  "#04060f"

    // ── MP4 Video Background ──────────────────────────────────
    MediaPlayer {
        id: bgPlayer
        source: Qt.resolvedUrl("background.mp4")
        loops:  MediaPlayer.Infinite
        autoPlay: true
        volume: 0   // video has no audio on login screen
    }

    VideoOutput {
        anchors.fill: parent
        source: bgPlayer
        fillMode: VideoOutput.PreserveAspectCrop
        opacity: 0.55   // darken so UI is readable

        // Fade in
        NumberAnimation on opacity {
            from: 0; to: 0.55
            duration: 2000
            easing.type: Easing.InOutCubic
        }
    }

    // ── Dark vignette overlay ─────────────────────────────────
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "rgba(4,6,15,0.45)" }
            GradientStop { position: 0.5; color: "rgba(4,6,15,0.10)" }
            GradientStop { position: 1.0; color: "rgba(4,6,15,0.70)" }
        }
    }

    // ── Starfield overlay (canvas particles) ─────────────────
    Canvas {
        id: stars
        anchors.fill: parent
        opacity: 0.6
        property var starData: []

        Component.onCompleted: {
            for (var i = 0; i < 180; i++) {
                starData.push({
                    x: Math.random() * width,
                    y: Math.random() * height,
                    r: Math.random() * 1.4 + 0.2,
                    a: Math.random(),
                    s: (Math.random() * 0.006 + 0.002) * (Math.random() < 0.5 ? 1 : -1)
                })
            }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            for (var i = 0; i < starData.length; i++) {
                var s = starData[i]
                s.a += s.s
                if (s.a >= 1.0 || s.a <= 0.0) s.s = -s.s
                ctx.beginPath()
                ctx.arc(s.x, s.y, s.r, 0, Math.PI * 2)
                ctx.fillStyle = "rgba(220,200,160," + (s.a * 0.7) + ")"
                ctx.fill()
            }
        }

        Timer {
            interval: 60; running: true; repeat: true
            onTriggered: stars.requestPaint()
        }
    }

    // ── Corner Ornaments ──────────────────────────────────────
    Repeater {
        model: [
            {ax: "left",  ay: "top",    sx: 1,  sy: 1 },
            {ax: "right", ay: "top",    sx: -1, sy: 1 },
            {ax: "left",  ay: "bottom", sx: 1,  sy: -1},
            {ax: "right", ay: "bottom", sx: -1, sy: -1},
        ]

        Canvas {
            width: 60; height: 60
            opacity: 0.3

            anchors {
                left:   modelData.ax === "left"   ? parent.left  : undefined
                right:  modelData.ax === "right"  ? parent.right : undefined
                top:    modelData.ay === "top"    ? parent.top   : undefined
                bottom: modelData.ay === "bottom" ? parent.bottom: undefined
                margins: 12
            }

            onPaint: {
                var c = getContext("2d")
                c.translate(modelData.sx < 0 ? width : 0, modelData.sy < 0 ? height : 0)
                c.scale(modelData.sx, modelData.sy)
                c.strokeStyle = "#c8a840"
                c.lineWidth = 1.5
                c.beginPath(); c.moveTo(2,58); c.lineTo(2,2); c.lineTo(58,2); c.stroke()
                c.lineWidth = 3
                c.beginPath(); c.moveTo(2,2); c.lineTo(16,2); c.stroke()
                c.beginPath(); c.moveTo(2,2); c.lineTo(2,16); c.stroke()
            }
        }
    }

    // ── Login Panel ───────────────────────────────────────────
    Rectangle {
        id: loginPanel
        anchors.centerIn: parent
        width: 380; height: 360
        color: "#E00a0c18"
        radius: 5

        // Animated gold border
        border.width: 1
        SequentialAnimation on border.color {
            loops: Animation.Infinite
            ColorAnimation { to: "#aac8a840"; duration: 2200; easing.type: Easing.InOutSine }
            ColorAnimation { to: "#44c8a840"; duration: 2200; easing.type: Easing.InOutSine }
        }

        // Inner top shine
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 1 }
            height: 1; color: "#18f0d090"
        }

        // Fade in on load
        opacity: 0
        NumberAnimation on opacity {
            from: 0; to: 1; duration: 1800; easing.type: Easing.OutCubic
            running: true
        }

        ColumnLayout {
            anchors { fill: parent; margins: 32 }
            spacing: 12

            // ── Logo / Header ────────────────────────────────
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 6

                // Custom PNG logo (put logo.png in theme folder)
                Image {
                    id: logoImg
                    Layout.alignment: Qt.AlignHCenter
                    source: Qt.resolvedUrl("logo.png")
                    width: 52; height: 52
                    fillMode: Image.PreserveAspectFit
                    visible: status === Image.Ready
                }

                // Fallback symbol if no logo.png
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "⚙"
                    font.pixelSize: 30
                    color: "#c8a840"
                    visible: logoImg.status !== Image.Ready
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "WELCOME BACK"
                    font.family: "Cinzel"
                    font.pixelSize: 15
                    font.letterSpacing: 4
                    color: "#f0d090"
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Warrior of Light"
                    font.family: "Cinzel"
                    font.pixelSize: 9
                    font.letterSpacing: 2
                    color: "#7a6030"
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#2ac8a840" }

            // ── User select ──────────────────────────────────
            ComboBox {
                id: userSelect
                Layout.fillWidth: true
                model: userModel
                currentIndex: userModel.lastIndex
                font.family: "Cinzel"; font.pixelSize: 10

                background: Rectangle {
                    color: "#110d1a2e"; border.color: "#44c8a840"; border.width: 1; radius: 3
                }
                contentItem: Text {
                    text: userSelect.currentText; color: "#c8b89a"
                    font: userSelect.font; verticalAlignment: Text.AlignVCenter; leftPadding: 10
                }
            }

            // ── Password ─────────────────────────────────────
            TextField {
                id: passwordField
                Layout.fillWidth: true
                placeholderText: "Password"
                echoMode: TextInput.Password
                font.family: "Cinzel"; font.pixelSize: 10
                color: "#c8b89a"
                leftPadding: 10; topPadding: 10; bottomPadding: 10

                background: Rectangle {
                    color: "#110d1a2e"
                    border.color: passwordField.activeFocus ? "#c8a840" : "#44c8a840"
                    border.width: 1; radius: 3
                    Behavior on border.color { ColorAnimation { duration: 200 } }
                }

                Keys.onReturnPressed: loginButton.clicked()
                Component.onCompleted: forceActiveFocus()
            }

            Text {
                id: errorText; Layout.alignment: Qt.AlignHCenter
                text: ""; color: "#e06060"
                font.family: "Cinzel"; font.pixelSize: 9; visible: text !== ""
            }

            // ── Login button ──────────────────────────────────
            Button {
                id: loginButton
                Layout.fillWidth: true
                text: "BEGIN JOURNEY"
                font.family: "Cinzel"; font.pixelSize: 10; font.letterSpacing: 2
                topPadding: 10; bottomPadding: 10

                background: Rectangle {
                    color: loginButton.pressed ? "#3a2a0a" : loginButton.hovered ? "#2a1e08" : "transparent"
                    border.color: loginButton.hovered ? "#c8a840" : "#44c8a840"
                    border.width: 1; radius: 3
                    Behavior on color       { ColorAnimation { duration: 150 } }
                    Behavior on border.color{ ColorAnimation { duration: 150 } }
                }
                contentItem: Text {
                    text: loginButton.text; font: loginButton.font
                    color: loginButton.hovered ? "#f0d090" : "#c8a840"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment:   Text.AlignVCenter
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                onClicked: {
                    var user = userModel.get(userSelect.currentIndex)
                    sddm.login(user.name, passwordField.text, sessionModel.lastIndex)
                }
            }
        }
    }

    // ── Clock ─────────────────────────────────────────────────
    Column {
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 22 }
        spacing: 4

        Text {
            id: clockDisplay
            anchors.horizontalCenter: parent.horizontalCenter
            text: "00:00:00"
            font.family: "JetBrains Mono, Courier New"
            font.pixelSize: 30
            color: "#c8a840"
            style: Text.Outline; styleColor: "#40000000"

            Timer {
                interval: 1000; running: true; repeat: true
                onTriggered: clockDisplay.text = Qt.formatTime(new Date(), "hh:mm:ss")
            }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(new Date(), "dddd, MMMM d")
            font.family: "Cinzel"; font.pixelSize: 10
            font.letterSpacing: 2; color: "#7a6030"
        }
    }

    // ── Login sound (mp3) ─────────────────────────────────────
    MediaPlayer {
        id: loginSound
        source: Qt.resolvedUrl("login.mp3")
        autoPlay: true
        volume: 0.7
    }

    // ── SDDM hooks ────────────────────────────────────────────
    Connections {
        target: sddm
        function onLoginFailed() {
            errorText.text = "Login failed — incorrect password"
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
    }
}
