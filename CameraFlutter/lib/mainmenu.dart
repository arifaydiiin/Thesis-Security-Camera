import 'dart:io';
import 'dart:typed_data';

import 'package:dashcam_flutter/oldpicture.dart';
import 'package:dashcam_flutter/wificheck.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

class MainMenu extends StatefulWidget {
  MainMenu({Key key}) : super(key: key);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
 String yol = "data:image/jpeg;base64,%2F9j%2F4AAQSkZJRgABAQEAAAAAAAD%2F2wBDAAoHCAkIBgoJCAkLCwoMDxkQDw4ODx8WFxIZJCAmJiQgIyIoLToxKCs2KyIjMkQzNjs9QEFAJzBHTEY%2FSzo%2FQD7%2F2wBDAQsLCw8NDx0QEB0%2BKSMpPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj4%2BPj7%2FxAAfAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgv%2FxAC1EAACAQMDAgQDBQUEBAAAAX0BAgMABBEFEiExQQYTUWEHInEUMoGRoQgjQrHBFVLR8CQzYnKCCQoWFxgZGiUmJygpKjQ1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4eLj5OXm5%2Bjp6vHy8%2FT19vf4%2Bfr%2FxAAfAQADAQEBAQEBAQEBAAAAAAAAAQIDBAUGBwgJCgv%2FxAC1EQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4%2BTl5ufo6ery8%2FT19vf4%2Bfr%2FwAARCADwAUADASEAAhEBAxEB%2F9oADAMBAAIRAxEAPwDyimnb3NGm4CGj8aejE9RRSDFFrj2DB9KXqKTSEgo70LcbExkUUBfoAA570UPUQvSmjGOKOgmOz7UlGoxKBRYd7hxSd6aJaCilcEHvmindFBSDrSXYAo6imHQO9JSAO9GaGQHakplhSd6YMSimBb7VHkd6jzCNxevp%2BVG2hAHWjBBp3sNge3pSUE2AUpx%2BNFtRIb1p3TpQygxj6Un8RpdBC8ZptERDu4o4P1pWBDetGarcpByOlGPSgVgpKQMO31p1FgGmg0DCge9ADaKYB60dqBAaKNx7gOlJSAO9Iad9dQRYpOzcdKRPmHp0o9aTetig6UHpmn1AOSKUCjmYhG603HNFxvuOoNFmyEN5p1BQlCnpS9AdgP3qU81WohvaloDqN70UWGLijvSuCBuvSkGaYBzmg0uo0IOvNHahgFFBIlLTH0EpKQCUtAxDSdKBItdDijvRfqJsbtA%2BlGKm47ifjS1W6EhPxxRmiwBRQUFA%2BlBId6DnNBQYpKAA0uMCgQlFDQwpKEAUY5ouIDQBTvoCEI20vpSfcYg60d6AuHekNFgDNFOzJCkNFhiUZxQMSigCznNJT6k26CA0oqWhh6c0g61V0MM0vfmpJQuaTqM1V9CrMQmii4BS9KlsQUgXii9gFpOaBoO1J2oT0EKPvUlDEJS%2BnrQ2Uw70lAMKTrQFhaKOhIlJQMKKaBBSUhhSUXAWk6H1oa5tBMsbcUh%2Bn4Cn1uPqN28Cj6UxMXFGMVIC00jvQl1ELRjPegrmA0CiwMMc0fWpEJigVUR3DnFHbmhhcSl5oBhzSYoELTTQA49KbSQxAKXvTEw%2FGk5oBARSU9xhS9qW2ghBRR1ASkoGHNFUBaYU0ipQhvPPPSnDke1U9UMM89qTtUq4rij60Ae9K7FuJRVWHYXtSA%2B1LUBaM0a2HcT6UdqCQpKCgpetNoQhopIYlLRcTENJTsMKMZ74o6khR3oYw7UhpAJS4obASlpbsBKQ0wEooGW8ZHXv0pv16UriGj3oA4zVMBTzSdqQW6h3oxRbqPQXj3paGwY2imAlFPZA0LRipJENJzT0HsLR2pDCigANFK4WEPWiqQCYoPWlcNApPxoDqBpaAEoobAU8Hg5plMBe9IaQIMUlO%2FcC1mo%2BvfrSvqJoXr1oyO%2FemMT%2BHFL%2FACoF0EzR260eg7CqecYoB%2BXk0mgDtSGgQUE1Q79BfpSVIgooGFGeKAE70vehiG55pc0WuMDSGjYA7UUXC4maKYhabSGFGadhWCjNJgIKSmMKDUhsWs%2FNmm%2FOT2PelyWExMe9FUhrYSlHIptAJ6UtJBsH4UY7dKBXDIAoxRZjEoph1DFJ0NKwXF9j1pKAbCiixAtFBYmOaKGAlFFkSJ3ootqMWkosAlFA0FFAXCkFABSUwCkpWbAsnriii4NaiYOaFPAPeq0YkH8NJSAWhetHQLdBAKXtSYDT9KdTGJn0oxRsAGlFJ3Ab0NKRTYhPwo7ilYYUUa2CwE80lAbAfvUd6ACigBKOaGISihDFpKdyQpKRXUKSgAooAsH1FJyBRpYW4nPejGKasNC%2FXrR904pXAQ8UDii%2BmgCij6UEgetFIoReKD0pgHWk%2BlABQelFxWF5BpBQxthmj8aLtAHakobABSUAHeihgHuaO9AtgpKQbi9qSmAlJQh3CigApKLgWsfxU3FAC59qOcZpNJC2ExQfzpg3diUuTQIDzRRYL2EoosVzBigcVVtAuHQUnNIBaSlayJF53UlCGFIOtAXFpOlC3ELTTTGg70ppDG0vehiCkxTQBSUA2JS0DCkoBBRSaC5Yo70A9Bp46UvvTDcXPtSZOOKRKVgFGcds0tx%2BQUlOwWCjvRYkKTPNMoO9L0pAJRQAtJ1otYApOaACkJoGLSUxIXOabR5DF5pM07CClqRiCigliUUwCkpWKFpKBFmm80thMTPFGcU73KCgUAJSZPanGJK3HUZ4pWGJR9KYxe1FGoCUUeYBRmkSgoouUFJQGwfQUlMAopCEFO70pAN%2BlAqugxTTTSEGaKtgFBrMApKYwNJQBZ6Gmn7uOaEw6i9uOKM%2BtKxLQopKYCdqXtQhpCUv4UdRdQ702goVqMUXJuFFTcN0JRTASinfQoKSjYgWkouOwGijQYlHegQuKQUD6BSUwF7UgpAgooGJRQAlFAFik%2BtMS3Dsc0UuouonNL0HNDiU2JTuaBaiEUhPahajFHSjmhgHak69aLEhQafL1GFJSEFHahjTCgdaJBYWkoHYKbQgClpsQUlIA7UlAwooBMKShE3CkosVfQKKEBYzRinsAnakxk%2BlVfQQo4OBzS%2B1QyeolLmjUtCd%2BeKDRcOoDmlNFxNCUn4UXBi0UBoN6dKWgApPegLB9aXpQwA0bi1Fupam0uUbRQQJmgUDFpKEJhSUDFpKfQQGkpXEJS0xiUUDLNIakXW42gGq6DbF9qMUkKwlFUmF%2Bwoo71ICdKWmkMKQ0hIXFJR1HoGMUGhoEJikouDFo6daLagJR3osDFpBS6CCkoW4XCiqAKbStqGwtFNoAopWGNoqhC0hqbXGizTadxMaOlOodtwFxSd6SloAmaWgS3E70UFAetKadrCDtScUXGFFK4go9qNgsJSA0dBi0cUE2Ck70AwoplISjNIW4UUDE6UUxBRQ2AU2luMWkpgFJRa4Fj1oNJCG0vNCY9AoouIKD6dKoYnendqV9RMb3oqrgg6c0VIC0Cp9AEo7U9RgDxSUCE7UooAD%2FKkouAtJ1pgFJSGFHegV7hnmihgJRQIKKChKKACkp3Atd6b3peghMjApc07WGHak7Cj7ImL2pPrSu7DjqFLjAppisIKXFJ6DsJ70UwFJptILC4pKOYNwo700wsGaKAsHaikISigYUlIBab2phsFFAhKKbGFJSJCigoKQ0AWTSUCCkpsfQWikJie9LQ2NDaWgAoFVuJsTFLSYwopAFNpi2ClpDbCkoEHaigANJQihKWmSJ3ooAKSgLi0d6XQQUlFigpDTAKSlfoBZ7nNNoQlEKX8aOgNCUDNC7iF6daKFqV0EoNMQdaKQWEzR%2BNDGHaii%2BodA70UyQ7UlBQUCkwA8UGhBuJ2pKBBRRzAFFACUtAxKKAEoouIO1JRcBaSgZZNN7VRNxBS0nuVqGKO9IQpptERgBS0B5B1ooAOwptMlbjh05pKXUbFpKBCUUFCikpiCkpgFFSAUUCCkpjEopAFJQxoWkoEFJTAKKALB44oOKGAh6UfWkK4vakNBSYgPanYqthXEopWAWkFHmADAxTRRydQsOHWkqWgFoFMBveigfMFFACUtMQhopgGaSpEFFAxKBQFgop9BBSUigpKYXCikIsHrSUDDH5UDFU9ri6iHpQvSl0GLSDmluIWgUX0C4jUYp3KCigQuaSkAlFAg70Ucw0LxSUALSUAJRQIKSi%2FQQtJQOwlBoGFFNsAoqQEpO9MQEc0UXAs03HrRcYfypaBW0ENFPoFg96DSsJC0lN7jEpaBhSUgFptFgQd6XNAhKKoYlOqWgEpPrQifMKPrRcoOaSgBabQAUtACUUdACkoAKKBCUUAWe2KbmjUBe1NzQPQKWjUAz8tHahALSUCAGigYUd6AENKKBMKbQMKXFAdBO9FFwCkosAuaSiwBmihAIaSgAzS0WASkpgLRSEJmkpjCigCx%2FOilfULDRRRzCCjpRcYUUAxe1IaIisFAoYwooAKO1K%2BotwFJ3zTuPYXFJ3ouFgooAQUUXEFJQNC0lCYAaKBCUUAFJQAtJSAKSmgCkoGf%2F9kA";
 
  @override
  Widget build(BuildContext context) {
 UriData data = Uri.parse(yol).data;
print(data.isBase64);
  
    return Scaffold(
      appBar: AppBar(
        title:Text("Güvenlik Kamerası")
      ),
      body:Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>WifiCheck()));
              },
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white)
                ),
                child: Center(child: Text("Kamera İzleme Odası")),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>OldPicture()));
              },
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white)
                ),
                child: Center(child: Text("Gelen Veriler")),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}