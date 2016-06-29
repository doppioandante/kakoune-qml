find_package(Qt5 ${QT_REQUIRED_VERSION} CONFIG REQUIRED Core Qml Quick)

set(boson_SOURCES main.cpp kakoune_client.h)

qt5_add_resources(boson_QRC boson.qrc)

add_executable(boson ${boson_SOURCES} ${boson_QRC})
qt5_use_modules(boson Qml Quick)
target_link_libraries(boson Qt5::Core Qt5::Qml Qt5::Quick)
