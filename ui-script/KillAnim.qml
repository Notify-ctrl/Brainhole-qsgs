import QtQuick 1.0

Item {
    id: root
/*
    property string skill: "阵亡台词"
    property string hero: "d:sunce+zhouyu"
    property real sceneHeight: 720
    property real sceneWidth: 1280

    width: sceneWidth
    height: sceneHeight
*/
    AnimatedImage {
        source: "../image/animate/util/speedline.gif"
        playing: true
        asynchronous: true
        opacity: 0.3
        width: sceneWidth
        height: sceneHeight
    }

    Image {
        id: killer
        source: "../image/generals/card/" + hero.split(":")[1].split("+")[0] + ".jpg"
        x: sceneWidth / 2 - width - 180
        y: - height - 100
        scale: 1.4
    }

    Item {
        Image {
            id: victim
            source: "../image/generals/card/" + hero.split(":")[1].split("+")[1] + ".jpg"
            x: sceneWidth / 2 + 150
            y: sceneHeight + 100
        }

        Rectangle {
            id: mask
            color: "black"
            opacity: 0
            anchors.fill: victim
        }

        Image {
            id: damageEmotion
            property int current: 0
            scale: 1.5
            anchors.centerIn: victim
            source: "../image/system/emotion/damage/" + current + ".png"
            visible: false
            NumberAnimation on current {
                id: emotion
                from: 0
                to: 4
                duration: 200
                running: false
            }
        }
    }

    Image {
        id: ji
        source: "../image/animate/util/ji.png"
        opacity: 0
        scale: 3
        x: sceneWidth / 2 - width / 2 - 30
        y: sceneHeight / 2 - 240
    }

    Image {
        id: po
        source: "../image/animate/util/po.png"
        opacity: 0
        scale: 3
        x: sceneWidth / 2 - width / 2 + 25
        y: sceneHeight / 2 - 100
    }

    FontLoader {
        id: bwk
        source: "../font/FZBWKSK.TTF"
    }

    Text {
        id: lastword
        text: skill
        width: victim.width * 2.8
        wrapMode: Text.WordWrap
        font.family: bwk.name
        font.pixelSize: 44
        style: Text.Outline
        color: "white"
        opacity: 0
        x: victim.x - victim.width * 0.2
        y: victim.y + victim.height * 0.75
    }

    SequentialAnimation {
        id: anim
        running: false
        ParallelAnimation {
            PropertyAnimation {
                target: killer
                property: "y"
                to: sceneHeight / 2 - killer.height / 2
                duration: 300
                easing.type: Easing.InQuad
            }
            PropertyAnimation {
                target: victim
                property: "y"
                to: sceneHeight / 2 - victim.height / 2
                duration: 300
                easing.type: Easing.InQuad
            }
        }

        ParallelAnimation {
            PropertyAnimation {
                target: killer
                property: "y"
                to: sceneHeight / 2 - killer.height / 2 + 10
                duration: 2640
            }
            PropertyAnimation {
                target: victim
                property: "y"
                to: sceneHeight / 2 - victim.height / 2 - 10
                duration: 2640
            }

            ParallelAnimation {
                PropertyAnimation {
                    target: mask
                    property: "opacity"
                    to: 0.7
                    duration: 200
                    easing.type: Easing.InQuad
                }
                PropertyAnimation {
                    target: victim
                    property: "opacity"
                    to: 0.7
                    duration: 200
                    easing.type: Easing.InQuad
                }
                PropertyAnimation {
                    target: lastword
                    property: "opacity"
                    to: 1
                    duration: 200
                    easing.type: Easing.InQuad
                }
                ScriptAction {
                    script: {
                        damageEmotion.visible = true
                        emotion.start()
                    }
                }
                SequentialAnimation {
                    PauseAnimation {
                        duration: 140
                    }
                    ParallelAnimation {
                        PropertyAnimation {
                            target: ji
                            property: "opacity"
                            to: 1
                            duration: 300
                            easing.type: Easing.InQuad
                        }
                        PropertyAnimation {
                            target: ji
                            property: "scale"
                            to: 0.5
                            duration: 300
                            easing.type: Easing.InQuad
                        }
                        SequentialAnimation {
                            PauseAnimation {
                                duration: 400
                            }
                            ParallelAnimation {
                                PropertyAnimation {
                                    target: po
                                    property: "opacity"
                                    to: 1
                                    duration: 300
                                    easing.type: Easing.InQuad
                                }
                                PropertyAnimation {
                                    target: po
                                    property: "scale"
                                    to: 0.5
                                    duration: 300
                                    easing.type: Easing.InQuad
                                }
                            }
                            PauseAnimation {
                                duration: 1200
                            }
                            PropertyAnimation {
                                target: root
                                property: "opacity"
                                to: 0
                                duration: 300
                            }
                        }
                    }
                }
            }
        }

        onCompleted: {
            container.animationCompleted()
        }
    }

    SequentialAnimation {
        id: anim2
        running: false
        ScriptAction {
            script: {
                killer.y = sceneHeight + 100
                victim.y = - victim.height - 100
            }
        }
        ParallelAnimation {
            PropertyAnimation {
                target: killer
                property: "y"
                to: sceneHeight / 2 - killer.height / 2
                duration: 300
                easing.type: Easing.InQuad
            }
            PropertyAnimation {
                target: victim
                property: "y"
                to: sceneHeight / 2 - victim.height / 2
                duration: 300
                easing.type: Easing.InQuad
            }
        }

        ParallelAnimation {
            PropertyAnimation {
                target: killer
                property: "y"
                to: sceneHeight / 2 - killer.height / 2 - 10
                duration: 2640
            }
            PropertyAnimation {
                target: victim
                property: "y"
                to: sceneHeight / 2 - victim.height / 2 + 10
                duration: 2640
            }

            ParallelAnimation {
                PropertyAnimation {
                    target: mask
                    property: "opacity"
                    to: 0.7
                    duration: 200
                    easing.type: Easing.InQuad
                }
                PropertyAnimation {
                    target: victim
                    property: "opacity"
                    to: 0.7
                    duration: 200
                    easing.type: Easing.InQuad
                }
                PropertyAnimation {
                    target: lastword
                    property: "opacity"
                    to: 1
                    duration: 200
                    easing.type: Easing.InQuad
                }
                ScriptAction {
                    script: {
                        damageEmotion.visible = true
                        emotion.start()
                    }
                }
                SequentialAnimation {
                    PauseAnimation {
                        duration: 140
                    }
                    ParallelAnimation {
                        PropertyAnimation {
                            target: ji
                            property: "opacity"
                            to: 1
                            duration: 300
                            easing.type: Easing.InQuad
                        }
                        PropertyAnimation {
                            target: ji
                            property: "scale"
                            to: 0.5
                            duration: 300
                            easing.type: Easing.InQuad
                        }
                        SequentialAnimation {
                            PauseAnimation {
                                duration: 400
                            }
                            ParallelAnimation {
                                PropertyAnimation {
                                    target: po
                                    property: "opacity"
                                    to: 1
                                    duration: 300
                                    easing.type: Easing.InQuad
                                }
                                PropertyAnimation {
                                    target: po
                                    property: "scale"
                                    to: 0.5
                                    duration: 300
                                    easing.type: Easing.InQuad
                                }
                            }
                            PauseAnimation {
                                duration: 1200
                            }
                            PropertyAnimation {
                                target: root
                                property: "opacity"
                                to: 0
                                duration: 300
                            }
                        }
                    }
                }
            }
        }

        onCompleted: {
            container.animationCompleted()
        }
    }

    SequentialAnimation {
        id: anim3
        running: false
        ScriptAction {
            script: {
                killer.y = sceneHeight / 2 - killer.height / 2
                victim.y = sceneHeight / 2 - victim.height / 2
                killer.x = sceneWidth + 100
                victim.x = - victim.width - 100
            }
        }
        ParallelAnimation {
            PropertyAnimation {
                target: killer
                property: "x"
                to: sceneWidth / 2 - killer.width - 180
                duration: 300
                easing.type: Easing.InQuad
            }
            PropertyAnimation {
                target: victim
                property: "x"
                to: sceneWidth / 2 + 150
                duration: 300
                easing.type: Easing.InQuad
            }
        }

        ParallelAnimation {
            PropertyAnimation {
                target: killer
                property: "x"
                to: sceneWidth / 2 - killer.width - 180 - 10
                duration: 2640
            }
            PropertyAnimation {
                target: victim
                property: "x"
                to: sceneWidth / 2 + 150 + 10
                duration: 2640
            }

            ParallelAnimation {
                PropertyAnimation {
                    target: mask
                    property: "opacity"
                    to: 0.7
                    duration: 200
                    easing.type: Easing.InQuad
                }
                PropertyAnimation {
                    target: victim
                    property: "opacity"
                    to: 0.7
                    duration: 200
                    easing.type: Easing.InQuad
                }
                PropertyAnimation {
                    target: lastword
                    property: "opacity"
                    to: 1
                    duration: 200
                    easing.type: Easing.InQuad
                }
                ScriptAction {
                    script: {
                        damageEmotion.visible = true
                        emotion.start()
                    }
                }
                SequentialAnimation {
                    PauseAnimation {
                        duration: 140
                    }
                    ParallelAnimation {
                        PropertyAnimation {
                            target: ji
                            property: "opacity"
                            to: 1
                            duration: 300
                            easing.type: Easing.InQuad
                        }
                        PropertyAnimation {
                            target: ji
                            property: "scale"
                            to: 0.5
                            duration: 300
                            easing.type: Easing.InQuad
                        }
                        SequentialAnimation {
                            PauseAnimation {
                                duration: 400
                            }
                            ParallelAnimation {
                                PropertyAnimation {
                                    target: po
                                    property: "opacity"
                                    to: 1
                                    duration: 300
                                    easing.type: Easing.InQuad
                                }
                                PropertyAnimation {
                                    target: po
                                    property: "scale"
                                    to: 0.5
                                    duration: 300
                                    easing.type: Easing.InQuad
                                }
                            }
                            PauseAnimation {
                                duration: 1200
                            }
                            PropertyAnimation {
                                target: root
                                property: "opacity"
                                to: 0
                                duration: 300
                            }
                        }
                    }
                }
            }
        }

        onCompleted: {
            container.animationCompleted()
        }
    }

    SequentialAnimation {
        id: anim4
        running: false
        ScriptAction {
            script: {
                killer.y = sceneHeight / 2 - killer.height / 2
                victim.y = sceneHeight / 2 - victim.height / 2
                victim.x = sceneWidth + 100
                killer.x = sceneWidth + 100
            }
        }
        ParallelAnimation {
            PropertyAnimation {
                target: killer
                property: "x"
                to: sceneWidth / 2 - killer.width - 180
                duration: 300
                easing.type: Easing.InQuad
            }
            PropertyAnimation {
                target: victim
                property: "x"
                to: sceneWidth / 2 + 150
                duration: 300
                easing.type: Easing.InQuad
            }
        }

        ParallelAnimation {
            PropertyAnimation {
                target: killer
                property: "x"
                to: sceneWidth / 2 - killer.width - 180 - 10
                duration: 2640
            }
            PropertyAnimation {
                target: victim
                property: "x"
                to: sceneWidth / 2 + 150 - 10
                duration: 2640
            }

            ParallelAnimation {
                PropertyAnimation {
                    target: mask
                    property: "opacity"
                    to: 0.7
                    duration: 200
                    easing.type: Easing.InQuad
                }
                PropertyAnimation {
                    target: victim
                    property: "opacity"
                    to: 0.7
                    duration: 200
                    easing.type: Easing.InQuad
                }
                PropertyAnimation {
                    target: lastword
                    property: "opacity"
                    to: 1
                    duration: 200
                    easing.type: Easing.InQuad
                }
                ScriptAction {
                    script: {
                        damageEmotion.visible = true
                        emotion.start()
                    }
                }
                SequentialAnimation {
                    PauseAnimation {
                        duration: 140
                    }
                    ParallelAnimation {
                        PropertyAnimation {
                            target: ji
                            property: "opacity"
                            to: 1
                            duration: 300
                            easing.type: Easing.InQuad
                        }
                        PropertyAnimation {
                            target: ji
                            property: "scale"
                            to: 0.5
                            duration: 300
                            easing.type: Easing.InQuad
                        }
                        SequentialAnimation {
                            PauseAnimation {
                                duration: 400
                            }
                            ParallelAnimation {
                                PropertyAnimation {
                                    target: po
                                    property: "opacity"
                                    to: 1
                                    duration: 300
                                    easing.type: Easing.InQuad
                                }
                                PropertyAnimation {
                                    target: po
                                    property: "scale"
                                    to: 0.5
                                    duration: 300
                                    easing.type: Easing.InQuad
                                }
                            }
                            PauseAnimation {
                                duration: 1200
                            }
                            PropertyAnimation {
                                target: root
                                property: "opacity"
                                to: 0
                                duration: 300
                            }
                        }
                    }
                }
            }
        }

        onCompleted: {
            container.animationCompleted()
        }
    }

    Component.onCompleted: {
        var animIndex = parseInt(Math.random() * 4);
        switch (animIndex) {
            case 0: anim.start(); break;
            case 1: anim2.start(); break;
            case 2: anim3.start(); break;
            case 3: anim4.start(); break;
            default: break;
        }
    }
}
