//
//  DetailsVC.swift
//  ArtBookCollector
//
//  Created by Taha Cakir on 12.03.2021.
//

import UIKit
import CoreData

class DetailsVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
//    bu iki eklenen şeyler biri picker ı kullanmaya yarıyor altta anlattım picker ı diğeri de ileri geri gelme işlemleri uygulamada,navigasyon böyle çalışıyor işte.Yönlendirme işlemleri delegate temsilci demek.
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    //    bu ikili veri aktarımı için varlar yüklediklerimi görüntüleyeyim diye..
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if chosenPainting != "" {
            saveButton.isHidden = true
//            bir de aşağıya else e false yazıcaksın ki geri gelsin.
//            saveButton.isEnabled = false
//            savebutton.ishidden = true dersen hiç gözükmez.Chosen da seçiyosun ki o kısımda gözükmesin sadece.
//            core Data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Painting")
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
//            bu üstteki karmaşık bir yapı buna calısmalısın!! idString olarak mutlaka döndür ve %@ formatıyla getir dedik
//            id si idstringlere eşit olanı getirecek.
//            name yapsaydın "name = %@",arguments self.chosenPaintings ama name aynı olabilir ondan dolayı..
//            predicate nspredicate ister.koşul yazıcaksın ve onu getiricek.Bir isim bir id bir resim çekicen yani hepsini değil
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name

                            
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    
                    
                    }
                    
                    
                }
            }catch{
                print("Error!!")
            }
            
            
            fetchRequest.returnsObjectsAsFaults = false
            
            
            
        }else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
            
        }
        
        
//        Recognizerss**
        //klavye sorunundan dolayı yazarken klavyeden alttan save butonuna ulaşamıyorsun kapanmıyor uygulam çünkü o sorun işin tap gesture

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
//        daha öncesinde fotoya basınca dedik artık nereye tıklarsan apatsın diyoruz anladın sen.. dışarıya tıklayınca bitti.
        view.addGestureRecognizer(gestureRecognizer)
//amaç şudur,görsele tıklayınca galeriye yönlendirecek ve sen de tıklayınca galeriye gidip foto yükleyeceksin onu kaydediceksin.Mevzu bu kadar.
        imageView.isUserInteractionEnabled = true
//        tıklanıyor mu true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
//        sonuncu da imageView a ekleme kısmıydı ki bununla iletişimde olsun diye.ilkinde aksiyon belirledik.
    
    
    
    
    }
    @objc func selectImage() {
//        galeriye götürücez.picker ile hatırlarsın
        let picker = UIImagePickerController()
//        açıklamasında bu kullanıcıdan video resim çekmek için yapılan şeydir bu fonk.
        picker.delegate = self
        picker.sourceType = .photoLibrary
//        source nerden olsun diyosun o da camera mı yoksa galeri mi onu seçtik.
        picker.allowsEditing = true
//        editleme işlemini okeyliyosun yani kırpabilir falan filan aslında
        present(picker, animated: true, completion: nil)
//        şuana kadar yaptığımız kullanıcı resme tıkladı kendi resmini seçti ama bi bakıyo yükleyemiyor,şuan gidip onları yükleyip halledecegiz alt tarafta.
        
    }
//    alttaki fonk media seçtikten sonra ne yapılacak işlemi yapıyo fonk un içinde de yazıyor zaten..Bir UIImage dönecek yani aslında onu tanımlıyoruz.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
//        burda yaptığımız da resmi info key istediğinden formulde dict type ta key pair value oldugundan array açıp nokta koyarsan edited var original var seç ordan hangisini istersen sadece o yüklensin..
//        butonu enable kısmına devam ediyorum altta,yani seçildikten sonra enable ettik butonu.
        
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
//        dismiss kapatmak için kullanılan fonk..
    }
    
    
    @objc func hideKeyboard() {
        view.endEditing(true)
//        bu fonk işin bittiğinde endEdit diyor,yani yazdın yazacagını kapat sonrasındayı saglıyor senden.
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
//        appDelegate core data için olacak öyle de bir sayfamız var zaten görebilrisin.App i ona eşitliyoruz ve contextle de baglıyoruz ki context e eşitleyelim gibisinden..Bu kısım ezber biraz*****
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
//        ********
//        segue.destination gibi aslında,app temsilcisi oluşturuyosun,app.shared.delegate ı appdelegate olarak kesin yaz diyosun.
        let newPainting = NSEntityDescription.insertNewObject(forEntityName:"Painting", into: context)
//        Attributes yazıcaz
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "year")
//            year kısmına baska bir şey yazarsa diye if let ile önlem aldık.. INt(yearText.text) let year diye tanımladığımızdan direk year yazabildik.
            
        }
        
        newPainting.setValue(UUID(), forKey: "id")
//        id için budur.
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
//        bu üstte image ı data haline zipliyoruz %40 ını aldık mesela datanın.
        newPainting.setValue(data, forKey: "image")
//        do try catch siz yazılmaz app i patlatır yoksa. yap dene bunu olmazsa hatayı yakala durdur.
        
        do {
            try context.save()
            print("Saved")
        } catch {
            print("error")
        }
//        mesaj yolluyor diğer VC lere
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
//        bir geri gitmek için save de onu yazıcam.Getirdi ama kaydettiğini göstermedi.
    }
//    baglarken bug oldu,aynı sorunda izle.
    
    




}
