//
//  YouversionReference.swift
//  Daily Gospel
//
//  Created by Damiaan on 19/08/18.
//  Copyright © 2018 Devian. All rights reserved.
//

import LectionaryScraper

extension Reference {
	static let youversionBooks = [
		"1_Ch":	"1CH",
		"2_Ch":	"2CH",
		"1_Co":	"1CO",
		"2_Co":	"2CO",
		"1_Jn":	"1JN",
		"2_Jn":	"2JN",
		"3_Jn":	"3JN",
		"1_M":	"1MA",
		"2_M":	"2MA",
		"1_P":	"1PE",
		"2_P":	"2PE",
		"1_R":	"1KI",
		"2_R":	"2KI",
		"1_S":	"1SA",
		"2_S":	"2SA",
		"1_Th":	"1TH",
		"2_Th":	"2TH",
		"1_Tm":	"1TI",
		"2_Tm":	"2TI",
		"Ac":	"ACT",
		"Ag":	"HAG",
		"Am":	"AMO",
		"Ap":	"REV",
		"Ba":	"BAR",
		"Col":	"COL",
		"Ct":	"SNG",
		"Dn":	"DAN",
		"Dt":	"DEU",
		"Ep":	"EPH",
		"Esd":	"EZR",
		"Est":	"EST",
		"Ex":	"EXO",
		"Ez":	"EZK",
		"Ga":	"GAL",
		"Gn":	"GEN",
		"Ha":	"HAB",
		"He":	"HEB",
		"Is":	"ISA",
		"Jb":	"JOB",
		"Jc":	"JAS",
		"Jg":	"JDG",
		"Jl":	"JOL",
		"Jn":	"JHN",
		"Jon":	"JON",
		"Jos":	"JOS",
		"Jr":	"LJE",
		"Jude":	"JUD",
		"Lc":	"LUK",
		"Lm":	"LAM",
		"Lv":	"LEV",
		"Ma":	"MAL",
		"Mc":	"MRK",
		"Mi":	"MIC",
		"Mt":	"MAT",
		"Na":	"NAM",
		"Nb":	"NUM",
		"Ne":	"NEH",
		"Os":	"HOS",
		"Ph":	"PHP",
		"Phm":	"PHM",
		"Pr":	"PRO",
		"Ps":	"PSA",
		"Qo":	"ECC",
		"Rm":	"ROM",
		"Rt":	"RUT",
		"Sg":	"WIS",
		"Si":	"SIR",
		"So":	"ZEP",
		"Tb":	"TOB",
		"Tt":	"TIT",
		"Za":	"ZEC"
	]
	
	var youversionBookAbbreviation: String? {
		return Reference.youversionBooks[bookAbbreviation]
	}
	
	public var youversion: String? {
		if let book = youversionBookAbbreviation {
			 return "\(book).\(chapter).\(verse)"
		} else {
			return nil
		}
	}
}
