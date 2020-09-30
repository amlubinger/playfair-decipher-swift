/*
 * Playfair decryption tool in Python by Andrew Lubinger
 *
 * Not necessarily the most efficient, but it's not brute force because that's... like... impossible.
 * Hill climbing kinda. 
 *
 * Enter your ciphertext into the string variable.
 * If you're confident that a word/phrase will be in the plaintext, set that variable too.
 * It'll use English frequency analysis for tetragrams, and then check for the expected phrase with the top scoring plaintexts.
 *
 * In Windows, after Swift is installed correctly, compile and run with the following commands in an x64 VS 2019 Command Prompt
 * swiftc %SWIFTFLAGS% -emit-executable -o C:/Users/andre/Documents/School/"LING 3801"/Playfair.exe C:/Users/andre/Documents/School/"LING 3801"/main.swift C:/Users/andre/Documents/School/"LING 3801"/tetragrams.swift
 * C:/Users/andre/Documents/School/"LING 3801"/Playfair.exe
 */

import Foundation

//User inputs
//Ciphertext, spaces can be included
let ciphertext = "PHZPT FPFPE RAOBT PBMWT NIRHN FBKNB ETNMT OAXET AWRAP AREPA INXFN XBZPA FPARL DFWAM ZBFRA RFODP PFOBN UAKNB BCARR PFMTO ARXDC BLBFQ OEPTX INUTC FACEQ IKPVN XFBLO HEKIV ONRAR EPACT BMBOC OLHPW PMPEW NXIKA HEKCD PNINP QAAMV KBKEB GPOFE KWNIF OBTPB MFAAR CTKBO BZKAR EPOXB CBLRH NFBOI FBCAK ROQBL BFXPF CTWNK BDVMI WKNAE GDPNE ANPMN PWPBC OBENK BDVQP NWPBT WIFON OFNOH IUXFA BEINW PMZAF PZNFT CTDPF EBWTZ KZOSI NIECK BOBTD ETMAW PAOKP CEYOK EKBAR FOXIN XNOAO FRXIX OEBKQ BLLBE TZHOC ENNAV DPWON SBCKT OVLNA ARSPN OCITC FANXG OROMA HLOKF OQBLB TEYOK WCOPS GENPI FKHFA KNAOD VOHIN PDINA MEBHL POARX IKTTF RAFNC IFAKE KBARF OXIHO AREOK URHPF ZEQAO FPURA PFTZC TFNTA TRHMV OIVNP MZBZL NQBLB XFKZL AOFIK AKICY ONXFX ETOWD KDLBP BMZTL AOHRE OHMOI BXOEB KQBLL BETFP WPKPE LNFXO REPAN UAFPZ RAOFE TTENI RAPFB CNMVK KPERA OINET PSOAR OEBLI AREOA RZBCW QIQPR EPABK RNANP MEUEN SBWPP SKADL NFIND NPFNF TOHCK ZNIBH MPKPH OINET KBAKB OZSBC RNROK BRARF HQZFN FBCRW OAPXW PCTNF KZARC WQIKD PURAR HAMZT ONSBP DLBTN VDXUE BCPPX NFINX FECBC RPERA OINET PSOAR OCWQI QPOFE TTENI RAARE POXBC OFNIZ QSPXQ AMCOX NWPAQ NIUGE SOVQB ZSTOV LSEMO EBDLR OQISP IFNXH YETRO IFHBM AECPE RAOBT PBMBC RAPNZ BSPXQ RPERT EZPVD XIFAF OXIRA ECBCO FESOV MZNIC AIMWQ NXNLP SWPFR BOINE TBCOB ZSTOV LPSKP EMPAB CNMVK VLREK PWQNF CTCNU EXOEB LAPAB KOBOB NLOND BLBKZ XNKYP MZQVT BOISV QTKOB PFCEO XUEAR BZETM HXPKB NIBLK YNIOF KPMAC TPSOA FRMAL NPUVK OAKTT FARNO EBFLO NPSKB OYKCY OONSB NUNED VQPON APDNI NXIPO XNIFZ KXOBP MKBVP FKZNA BCOBA OBMLN IBNOE YDBDC ETFOM ACOEO IFBCR NROKB RARFH QIVEB NOHLC AVKHP QIKPV ENXEP NXIXE TOWDK DLBPB MZTLA OHREO HMOIB XOEBK QBLLB ETECE BUXDB XFNXB CNMMP ONMAK TIFQV BCREA PEPMA LVEBL DXFUA FNBLE TQVCE YOEPN XNCTO APFNL MTLMH APKNF AFOXI RAECC RWPEX WNXIC EOXDB LAPKN ITDPS KZIHD PBLTP IEAOK CTDPS QVTVK BCPEF BCAMX ORNON ARKTQ NWNIF OBTPB MENAR KTQNW NIFBC OBBCR PERAO INETK TXINX WOBZK HFACV MPGPR MWOKB LBBKR NNWKB SBBKE KPNLE PABOX IKZRI IVNPM ZRAPM AKICY ONXCX FAWNQ BKZEP CNFAS PKBHO AREOK URHPF PMDPR AVRMP BZRAA MVOIV ZVMZN IFBNE TCOLR WZBIF KPHOK DYOAR TFZRI BBCNF RNNOO AVDAM IBXOE BKQBL LBETV NIFEU".replacingOccurrences(of: " ", with: "").lowercased()
//An expected phrase or word that should be in the plain text.
let expectedPhrase = "Reconnoiter".replacingOccurrences(of: " ", with: "").lowercased()

//Decipher using the key
//Takes the grid as a paramter
//Returns the plaintext
func decipher(grid: [[String]]) -> String {
  //Use the grid to decipher
  var answer = ""
  for pairPos in stride(from: 0, to: ciphertext.count, by: 2) {
    //Ciphertext characters 0 and 1
    let cc0 = String(ciphertext[ciphertext.index(ciphertext.startIndex, offsetBy: pairPos)])
    let cc1 = String(ciphertext[ciphertext.index(ciphertext.startIndex, offsetBy: pairPos + 1)])
    //Ciphertext positions in grid: i is row, j is column
    var cp0i = -1
    var cp1i = -1
    var cp0j = -1
    var cp1j = -1
    //Plaintext characters found from grid
    var pc0 = ""
    var pc1 = ""
    //Find the ciphertext characters in the grid
    for i in 0...4 {
      for j in 0...4 {
        if(grid[i][j] == cc0) {
          cp0i = i
          cp0j = j
        }
        if(grid[i][j] == cc1) {
          cp1i = i
          cp1j = j
        }
      }
    }
    if(cp0i == cp1i) {
      //Same row, get character to the left
      if(cp0j - 1 < 0) {
        pc0 = grid[cp0i][4]
      } else {
        pc0 = grid[cp0i][cp0j - 1]
      }
      if(cp1j - 1 < 0) {
        pc1 = grid[cp1i][4]
      } else {
        pc1 = grid[cp1i][cp1j - 1]
      }
    } else if(cp0j == cp1j) {
      //Same columm, get character above
      if(cp0i - 1 < 0) {
        pc0 = grid[4][cp0j]
      } else {
        pc0 = grid[cp0i - 1][cp0j]
      }
      if(cp1i - 1 < 0) {
        pc1 = grid[4][cp1j]
      } else {
        pc1 = grid[cp1i - 1][cp1j]
      }
    } else {
      //Make a rectangle
      pc0 = grid[cp0i][cp1j]
      pc1 = grid[cp1i][cp0j]
    }
    answer += pc0 + pc1
  }

  return answer
}

var shouldTryAgain = false
var usedGrids = Set<[[String]]>()
var on1 = -1
var on2 = -1
var on3 = -1
var on4 = -1
var ooption = -1

//Backtrack one step to get the last grid.
//This is useful when we can't find a new grid from the current one, so we try the last known grid.
//Takes grid as parameter and uses o-variables to backtrack and return the old grid.
func backtrack(grid: [[String]]) -> [[String]] {
  //Do the change again. For each case, reverse is the same code as forward since they're all swaps or flips.
  var oldGrid = grid
  switch ooption {
    case 0:
      //swap rows
      let row = oldGrid[on1]
      oldGrid[on1] = oldGrid[on2]
      oldGrid[on2] = row

    case 1:
      //swap columns
      for i in 0...4 {
        let char = oldGrid[i][on1]
        oldGrid[i][on1] = oldGrid[i][on2]
        oldGrid[i][on2] = char
      }

    case 2:
      //horizontal flip
      for i in 0...4 {
        var char = oldGrid[i][0]
        oldGrid[i][0] = oldGrid[i][4]
        oldGrid[i][4] = char
        char = oldGrid[i][1]
        oldGrid[i][1] = oldGrid[i][3]
        oldGrid[i][3] = char
      }

    case 3:
      //vertical flip
      for i in 0...4 {
        var char = oldGrid[0][i]
        oldGrid[0][i] = oldGrid[4][i]
        oldGrid[4][i] = char
        char = oldGrid[1][i]
        oldGrid[1][i] = oldGrid[3][i]
        oldGrid[3][i] = char
      }

    default:
      //character swap
      let char = oldGrid[on1][on2]
      oldGrid[on1][on2] = oldGrid[on3][on4]
      oldGrid[on3][on4] = char
  }
  ooption = -1 //reset it so we don't try again with the same steps
  return oldGrid
}

//Get a new grid.
//Either make it from a key or from a used grid.
//If making from a used grid, make sure it's not in the usedGrids set.
func gridFrom(key: String) -> [[String]] {
  //usedGrids.removeAll()
  var newGrid = [["x","x","x","x","x"],["x","x","x","x","x"],["x","x","x","x","x"],["x","x","x","x","x"],["x","x","x","x","x"]]
  var pos = 0
  for char in key {
    newGrid[pos / 5][pos % 5] = String(char)
    pos += 1
  }
  usedGrids.insert(newGrid)
  return newGrid
}
func gridFrom(grid: [[String]]) -> [[String]] {
  //Just make small changes, like row/column swaps, horizontal/vertical flips, full swap, or character swap.
  var newGrid = grid
  var attempts = 0
  var n1 = -1
  var n2 = -1
  var n3 = -1
  var n4 = -1
  var option = -1
  while(usedGrids.contains(newGrid) && attempts < 100000) {
    attempts += 1
    newGrid = grid
    n1 = Int.random(in: 0...4)
    n2 = Int.random(in: 0...4)
    n3 = Int.random(in: 0...4)
    n4 = Int.random(in: 0...4)
    option = Int.random(in: 0...50)
    switch option {
      case 0:
        //swap rows
        let row = newGrid[n1]
        newGrid[n1] = newGrid[n2]
        newGrid[n2] = row

      case 1:
        //swap columns
        for i in 0...4 {
          let char = newGrid[i][n1]
          newGrid[i][n1] = newGrid[i][n2]
          newGrid[i][n2] = char
        }

      case 2:
        //horizontal flip
        for i in 0...4 {
          var char = newGrid[i][0]
          newGrid[i][0] = newGrid[i][4]
          newGrid[i][4] = char
          char = newGrid[i][1]
          newGrid[i][1] = newGrid[i][3]
          newGrid[i][3] = char
        }

      case 3:
        //vertical flip
        for i in 0...4 {
          var char = newGrid[0][i]
          newGrid[0][i] = newGrid[4][i]
          newGrid[4][i] = char
          char = newGrid[1][i]
          newGrid[1][i] = newGrid[3][i]
          newGrid[3][i] = char
        }

      default:
        //character swap
        let char = newGrid[n1][n2]
        newGrid[n1][n2] = newGrid[n3][n4]
        newGrid[n3][n4] = char
    }
  }
  if(attempts == 100000) {
    if(ooption != -1) {
      //Go back one step and try again
      newGrid = gridFrom(grid: backtrack(grid: newGrid))
    } else {
      //Start over with a new random key starting point
      shouldTryAgain = true
    }
  } else {
    //Found a new grid, keep track of this change
    on1 = n1
    on2 = n2
    on3 = n3
    on4 = n4
    ooption = option
    usedGrids.insert(newGrid)
  }
  return newGrid
}

//Calculate the score of the plaintext.
//Specifically, find the tetragrams in the plaintext and add their english frequency value to the score.
//score = sum(quartet.each { $0.englishFreq })
//Higher score is better
func getScore(text: String) -> Double {
  var score = 0.0
  for pairPos in 0..<text.count - 3 {
    let quartet = String(text[text.index(text.startIndex, offsetBy: pairPos)...text.index(text.startIndex, offsetBy: pairPos + 3)])
    if let englishFrequency = tetragrams[quartet.uppercased()] { //make it uppercased because i dont feel like changing tetragrams rn lol
      score += englishFrequency
    }
  }
  return score
}

//Some variables
var tries = 0
var alphabet = "abcdefghiklmnopqrstuvwxyz" //without 'j' as usual
var key = alphabet.shuffled()
var topGrid = gridFrom(key: String(key)) //[["x","x","x","x","x"],["x","x","x","x","x"],["x","x","x","x","x"],["x","x","x","x","x"],["x","x","x","x","x"]]
var topNewGrid = topGrid
var topScore = -1.0
var topNewScore = -1.0
var topPlaintext = ""
var keepTrying = true

//Run playfair over and over with different keys until we find the expected phrase
//in the plaintext. At that point, show the user the possible plaintext and ask if it is
//correct. If not correct, continue. If correct, print the key.
while(keepTrying && tries < 10000000000) { //try until correct with a maximum of ~10 billion attempts, arbitrarily chosen
  var grid = [["x","x","x","x","x"],["x","x","x","x","x"],["x","x","x","x","x"],["x","x","x","x","x"],["x","x","x","x","x"]]
  if(tries % 1000000 == 0 || shouldTryAgain) {
    //let's get a new random key to start from instead of just making lots of minor changes.
    shouldTryAgain = false
    key = alphabet.shuffled()
    topNewScore = -1.0
    grid = gridFrom(key: String(key))
  } else {
    grid = gridFrom(grid: topNewGrid)
  }
  let plaintext = decipher(grid: grid)
  let score = getScore(text: plaintext)
  //Higher score is better
  if(score >= topNewScore) {
    topNewScore = score
    topNewGrid = grid
    print("\n\n")
    print(plaintext)
    print(score)
    print(grid)
    print("\n\n")
    if(score >= topScore) {
      topScore = score
      topPlaintext = plaintext
      topGrid = grid
    }
  }
  if(score == topScore && (plaintext.contains(expectedPhrase))) {
    print("Does this plaintext look correct? (y/n)\n")
    print(plaintext)
    keepTrying = readLine() == "n" //Keep trying if user says not correct.
  }
  tries += 1
}
if(!keepTrying) {
  print("Grid: \(topGrid)")
  print("It took \(tries) guesses!")
} else {
  print("The best I could do:\n" + topPlaintext)
  print("Grid: \(topGrid)")
}
