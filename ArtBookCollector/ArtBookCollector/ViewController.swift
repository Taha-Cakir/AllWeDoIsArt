//
//  ViewController.swift
//  ArtBookCollector
//
//  Created by Taha Cakir on 12.03.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    

    @IBOutlet weak var tableView: UITableView!
//    isim çek görsel çekme görsel çekmek uzun sürer id de olur
    var nameArray = [String]()
    var idArray = [UUID]()
//    bu ikili core data hastagi için açıldı.
    var selectedPainting = ""
    var selectedPaintingId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
//        artı butonu için bunlar..
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
    
    
        getData()
    
    }
//    bi anlatayım sana bunu, didload bir kere calıstıgından Detailstan aldığımız newData yı orda çalıştırmak olmaz çünkü her yeni datada bu güncellenecek. Burda observer ekliyosun yeni bildiirm var mı diye,getData bizim selectorumuz ama onu da normal func tan objc ye çevirdik tabi,name de newData birebir aynısı VCdekiyle.
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    @ objc func getData() {
//bu alttaki ikili çoklu aynı şeyi göstermesin diye yapılmış bir şeydir. ikişer defa aynı göstermesin diye
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
//
        let  appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
//        details ta felen dataları buraya çekiyorum aslında farklı bir işlem yok..
//        fetch getirmek demektir
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Painting")
        fetchRequest.returnsObjectsAsFaults = false
//        cashten okuma bu aslında bu büyük veriler için aslında. istekleri getir sonuçalarını da getir diyoruz böylelikle..
        
        do {
//            let results yaptık bu bunu for döngüsüyle veya if letle getirirken bir değişkene atayalım hepsini try olarak.
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
//                NS olan core data objesidir.
                        for result in results as! [NSManagedObject]{
                            if let name = result.value(forKey: "name") as? String {
                                self.nameArray.append(name)
                            }
                            if let id = result.value(forKey: "id") as? UUID {
                                self.idArray.append(id)
                                
                            }
                
            }

                self.tableView.reloadData()
//                yeni data geldi güncelle kendini dedik..
                
            }
            
        }catch {
            print("Error")
        }
        
    }
    
    
    
    
    
    
    
    
    
    @objc func addButtonClicked () {
        selectedPainting = ""
//        bunu yapmamızın nedeni artıya tıklanırsa bir şey seçmedik boş demek.
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.chosenPainting = selectedPainting
            destinationVC.chosenPaintingId = selectedPaintingId
//            böylelikle ikisini de baglamış olduk seguelerle
            
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        ama bir name e tıklanırsa o name dolu bana onu göster diyoruz.
        selectedPainting = nameArray[indexPath.row]
        selectedPaintingId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
//    kullanıcının editlerini anlmak için
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
//            kalıcı olarak container a koy dedik persisten kalıcı demektir.
            
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Painting")
//            idString oluşturuyosun nerden alırsın id dizisinden,hangi id ? olduğun index ve rowdakini ne olarak uuidString olarak..
            let idString = idArray[indexPath.row].uuidString
//            predicate tek veri almak demek.
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                do {
                                    try context.save()
                                }catch{
                                    print("Error")
                                }
//                                isimden çekseydik break zorunluydu çünkü buldugun an for loop u bitsin demektir ama id aslında gereksiz çünkü uniqe id. id kullanamazsan break olmalı.
                                break
//                                bu işlem işte core data dan siliyor,geri dönüşü yok bunun.. diyoruz ki tek bi predicate oluşturduk evet.. sonra hatalarla döneyim mi diyo yok diyoruz.Sonra hata yakalama dene diyosun sonuçları try et context ve fetch requestle aldık.NsManaged core data bu sistem olarak dataları görüyor ondan onun dilinden yazıyoruz. id mi tanımlıyorum id m birbirine eşse rowdakiyle,context i sil demek hangisini result olan context i.
                            }
                        }
                    }
                }

                
            }catch{
                print("Error")
            }
        }
    }
    
    
    


}

