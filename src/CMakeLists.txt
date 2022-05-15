find_package(Qt5 ${QT_REQUIRED_VERSION} CONFIG REQUIRED Core Qml Quick)

set(singlewindow_SOURCES singlewindow.cpp kakoune_client.h)
qt5_add_resources(singlewindow_QRC resources.qrc)

add_executable(singlewindow ${singlewindow_SOURCES} ${singlewindow_QRC})
target_link_libraries(singlewindow Qt5::Core Qt5::Qml Qt5::Quick)
