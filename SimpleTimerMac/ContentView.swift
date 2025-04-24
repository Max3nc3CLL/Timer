//
//  ContentView.swift
//  SimpleTimerMac
//
//  Created by Maxence Cailleau on 22/04/2025.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @ObservedObject var timerManager: TimerManager
    @StateObject private var taskManager = TaskManager()

    var body: some View {
        ZStack {
            // Fond avec effet de flou
            Color.black
                .opacity(0.1)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack(spacing: 8) {
                // Timer section
                VStack(spacing: 10) {
                    Text(timerManager.timeString)
                        .font(.system(size: 48, weight: .regular, design: .monospaced))
                        .foregroundColor(.white)

                    HStack(spacing: 25) {
                        Button(action: { timerManager.toggleTimer() }) {
                            Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())

                        Button(action: { timerManager.resetTimer() }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())

                        Button(action: { timerManager.adjustTime(by: -60) }) {
                            Image(systemName: "minus")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())

                        Button(action: { timerManager.adjustTime(by: 60) }) {
                            Image(systemName: "plus")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, 5)
                
                Divider()
                    .background(Color.white.opacity(0.15))
                
                // Task list section
                TaskListView(taskManager: taskManager)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ContentView(timerManager: TimerManager())
        .frame(width: 300, height: 400)
        .preferredColorScheme(.dark)
}
