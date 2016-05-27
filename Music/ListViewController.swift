
import UIKit
import MediaPlayer

class ListViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediaItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MusicTableViewCell
        cell.songName.text = mediaItems[indexPath.row].title!
        cell.songAlbum.text = mediaItems[indexPath.row].albumTitle
        if cell.songAlbum.text == ""{
            cell.songAlbum.text = "Unknown"
        }
        let url = mediaItems[indexPath.row].valueForProperty(MPMediaItemPropertyAssetURL) as! NSURL
        let item = AVPlayerItem(URL: url)
        let info = item.asset.metadata
        cell.artwork.image = UIImage(named: "placeholder")
        for item in info {
            if item.commonKey  == "artwork" {
                cell.artwork.image = UIImage(data: item.value as! NSData)
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        performSegueWithIdentifier("playMusic", sender: self)
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "playMusic"{
            if let index = tableView.indexPathsForSelectedRows?[0].item{
                if let destination = segue.destinationViewController as? ViewController{
                    destination.playFlag = true
                    destination.playItem = index
                    soundPlayer.stop()
                }
            }
        }
    }
}
