//
//  DataProvider.swift
//  Networking
//
//  Created by pro2017 on 07/10/2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import UIKit

class DataProvider: NSObject {
    
    // В это свойство будем передавать параметры конфигурации и использовать его для настройки сессии
    private var downloadTask: URLSessionDownloadTask!
    
    // Текущий путь к файлу
    var fileLocation: ((URL) -> ())?
    
    // Текущее % загрузки
    var progressBar: ((Double) -> ())?
    
    // Настраиваем параметры конфигурации дляя фоновой загрузки
    private lazy var bgSession: URLSession = {
        
        // Создаем свойство, которое будет определять поведение нашей сессии при загрузке и выгрузке данных. В id предаем BundleID.
        let config = URLSessionConfiguration.background(withIdentifier: "com.sewego.Networking")
        
        // Могут ли фоновые задачи быть запланированы по усмотрению системы для лучшей производительности
        //config.isDiscretionary = true
        
        // По окончанию загрузки наше приложение запустится в фоновом режиме
        config.sessionSendsLaunchEvents = true
        
        // Возвращаем URLSession предварительно подписав класс под URLSessionDelegate
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    
    // MARK: - Начало загрузки
    
    // Вызываем функции начала загрузки
    func stardDownload(with urlString: String) {
        
        // Создаем и проверяем URL
        if let url = URL(string: urlString) {
            
            
            //Создаем DownloadTaskSession, она копирует предоставленые параметры конфигурации из ленивого свойства bgSession. После запуска сессии ее дальнейшая настройка невозможна.
            downloadTask = bgSession.downloadTask(with: url)
            
            // Указываем, что загрузка не начнется раньше заданного времени addingTimeInterval(3)
            downloadTask.earliestBeginDate = Date().addingTimeInterval(3)
            
            // Наиболее вероетная верхняя граница веса данных для выгрузки на сервер
            downloadTask.countOfBytesClientExpectsToSend = 512
            
            // Наиболее вероетная верхняя граница веса данных для загрузки
            downloadTask.countOfBytesClientExpectsToReceive = 100 * 1024 * 1024
            
            // Начинаем запрос
            downloadTask.resume()
            
        }
    }
    
    // Метод, который может прервать загрузку данных
    func stopDownload() {
        downloadTask.cancel()
    }
    
}


// MARK: - URLSessionDelegate


extension DataProvider: URLSessionDelegate {
    
    // Вызываем метод, который будет срабатывать при завершении всех фоновых задач.
    /// Т.к в конфигурации стоит config.sessionSendsLaunchEvents = true, соответственно наше приложение запуститься при завершении всех фоновых задач и вызовет метод в AppDelegate, который будет перехватывать id нашей сесии (handleEventsForBacgroundURLSession)
     
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
        // Т.к у нас есть метод для сопоставления id сессий мы вызываем его передав в блок id нашей сессии
        DispatchQueue.main.async {
            guard
                let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                
                // В эту константу мы передаем захваченое значение из bgSessionCompletionHandler класса AppDelegate
                let completionHandler = appDelegate.bgSessionCompletionHandler
            else { return }
            
            // Обнуляем значение этого свойства
            appDelegate.bgSessionCompletionHandler = nil
            
            // Вызываем исходный блок, что бы уведомить систему о том, что загрузка была завершена
            completionHandler()
            
        }
    }
}

// MARK: - URLSessionDownloadDelegate

// Здесь мы будем реализовывать получение ссылки на загруженый файл и отображение прогресса загрузки
extension DataProvider: URLSessionDownloadDelegate {
    
    // Значение location имеет ссылку на временную директрорию по которой сохраняется файл. Файл нужно либо открыть для чтения либо переместить в другую постоянную директорию.
    /// Файл будем открывать в асинхронной очереди
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        print(location.absoluteString)
        
        // Используем свойство класса, в котором мы будем захватывать текущий путь к файлу
        DispatchQueue.main.async {
            self.fileLocation?(location)
        }
    }
    
    // Отображаем ход выполнения загрузки
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        // Проверяем размер файла
        guard totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown else { return }
        
        // Определяем процент загрузки файла
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        
        print("Progress: \(progress)")
        
        DispatchQueue.main.async {
            self.progressBar?(progress)
        }
    }
    
}

extension DataProvider: URLSessionTaskDelegate {
    
    // После того как подключение к сети станед доступным получаем call-back в методе
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        
    }
}
