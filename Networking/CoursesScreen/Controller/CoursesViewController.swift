//
//  CoursesViewController.swift
//  Networking
//
//  Created by Alexey Efimov on 06.09.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit

class CoursesViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var courses = [CoursesData]()
    var courseURL: String?
    var courseName: String?
    
    let url = "https://swiftbook.ru//wp-content/uploads/api/api_courses"
    let placeholder = "https://jsonplaceholder.typicode.com/posts"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tableView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
}

// MARK: - Fetch DATA

extension CoursesViewController {
    
    func fetchData() {
        
        NetworkManager.showCourses(with: url) { courses in
            self.courses = courses
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchDataWithAlamofire() {
        
        // Вызываем статический метод .sendRequest а после в клоужере обновляем данные
        AlamofireNetworkRequest.sendRequest(url: url) { (courses) in
            self.courses = courses
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func postRequest() {
        
        // Отправляем и получаем данные для обновления
        AlamofireNetworkRequest.postRequest(url: placeholder) { (courses) in
            self.courses = courses
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func putRequest() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "Description" else { return }
        let webView = segue.destination as! WebViewController
        
        guard let courseURL = self.courseURL, let courseName = self.courseName else { return }
        webView.courseURL = courseURL
        webView.selectedCourse = courseName
    }
}

// MARK: Table View Data Source

extension CoursesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        configureCell(cell: cell, for: indexPath)
        
        return cell
    }
    
    private func configureCell(cell: TableViewCell, for indexPath: IndexPath) {
        
        let courseInfo = self.courses[indexPath.row]
        
        cell.courseNameLabel.text = courseInfo.name
        
        guard let numberOfLessons = courseInfo.numberOfLessons else { return }
        cell.numberOfLessons.text = "Number of lessons: \(numberOfLessons)"
        
        guard let numberOfTests = courseInfo.numberOfTests else { return }
        cell.numberOfTests.text = "Number of tests: \(numberOfTests)"
        
        guard let imageUrl = URL(string: "\(courseInfo.imageURL)") else { return }
        guard let imageData = try? Data(contentsOf: imageUrl) else { return }
        cell.courseImage.image = UIImage(data: imageData)
        
        cell.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
}

// MARK: Table View Delegate

extension CoursesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCourse = courses[indexPath.row]
        courseURL = currentCourse.link
        courseName = currentCourse.name
        performSegue(withIdentifier: "Description", sender: self)
    }
}

