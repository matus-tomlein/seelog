//
//  ReportBarChartSelection.swift
//  seelog
//
//  Created by Matus Tomlein on 23/09/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation

class ReportBarChartSelection {
    var reportViewController: ReportViewController
    var items: [String] = [] {
        didSet {
            self.reportViewController.collectionView.reloadData()
        }
    }

    var flaggedItems: [String] {
        get {
            return items.map { flag(country: $0) }
        }
    }

    init(reportViewController: ReportViewController) {
        self.reportViewController = reportViewController
    }

    func flag(country: String) -> String {
        if let countryCode = self.countryCodeMapping[country] {
            let base = 127397
            var usv = String.UnicodeScalarView()
            for i in countryCode.utf16 {
                if let scalar = UnicodeScalar(base + Int(i)) {
                    usv.append(scalar)
                }
            }
            return String(usv)
        } else {
            return country
        }
    }

    let countryCodeMapping = [
        "IDN": "ID",
        "MYS": "MY",
        "CHL": "CL",
        "BOL": "BO",
        "PER": "PE",
        "ARG": "AR",
        "CYP": "CY",
        "IND": "IN",
        "CHN": "CN",
        "ISR": "IL",
        "PSX": "PS",
        "LBN": "LB",
        "ETH": "ET",
        "SDS": "SS",
        "SOM": "SO",
        "KEN": "KE",
        "PAK": "PK",
        "MWI": "MW",
        "TZA": "TZ",
        "SYR": "SY",
        "FRA": "FR",
        "SUR": "SR",
        "GUY": "GY",
        "KOR": "KR",
        "PRK": "KP",
        "MAR": "MA",
        "SAH": "EH",
        "CRI": "CR",
        "NIC": "NI",
        "COG": "CG",
        "COD": "CD",
        "BTN": "BT",
        "UKR": "UA",
        "BLR": "BY",
        "NAM": "NA",
        "ZAF": "ZA",
        "MAF": "MF",
        "SXM": "SX",
        "OMN": "OM",
        "UZB": "UZ",
        "KAZ": "KZ",
        "TJK": "TJ",
        "LTU": "LT",
        "BRA": "BR",
        "URY": "UY",
        "MNG": "MN",
        "RUS": "RU",
        "CZE": "CZ",
        "DEU": "DE",
        "EST": "EE",
        "LVA": "LV",
        "NOR": "NO",
        "SWE": "SE",
        "FIN": "FI",
        "VNM": "VN",
        "KHM": "KH",
        "LUX": "LU",
        "ARE": "AE",
        "BEL": "BE",
        "GEO": "GE",
        "MKD": "MK",
        "ALB": "AL",
        "AZE": "AZ",
        "KOS": "XK",
        "TUR": "TR",
        "ESP": "ES",
        "LAO": "LA",
        "KGZ": "KG",
        "ARM": "AM",
        "DNK": "DK",
        "LBY": "LY",
        "TUN": "TN",
        "ROU": "RO",
        "HUN": "HU",
        "SVK": "SK",
        "POL": "PL",
        "IRL": "IE",
        "GBR": "GB",
        "GRC": "GR",
        "ZMB": "ZM",
        "SLE": "SL",
        "GIN": "GN",
        "LBR": "LR",
        "CAF": "CF",
        "SDN": "SD",
        "DJI": "DJ",
        "ERI": "ER",
        "AUT": "AT",
        "IRQ": "IQ",
        "ITA": "IT",
        "CHE": "CH",
        "IRN": "IR",
        "NLD": "NL",
        "LIE": "LI",
        "CIV": "CI",
        "SRB": "RS",
        "MLI": "ML",
        "SEN": "SN",
        "NGA": "NG",
        "BEN": "BJ",
        "AGO": "AO",
        "HRV": "HR",
        "SVN": "SI",
        "QAT": "QA",
        "SAU": "SA",
        "BWA": "BW",
        "ZWE": "ZW",
        "BGR": "BG",
        "THA": "TH",
        "SMR": "SM",
        "HTI": "HT",
        "DOM": "DO",
        "TCD": "TD",
        "KWT": "KW",
        "SLV": "SV",
        "GTM": "GT",
        "TLS": "TL",
        "BRN": "BN",
        "MCO": "MC",
        "DZA": "DZ",
        "MOZ": "MZ",
        "SWZ": "SZ",
        "BDI": "BI",
        "RWA": "RW",
        "MMR": "MM",
        "BGD": "BD",
        "AND": "AD",
        "AFG": "AF",
        "MNE": "ME",
        "BIH": "BA",
        "UGA": "UG",
        "CUB": "CU",
        "HND": "HN",
        "ECU": "EC",
        "COL": "CO",
        "PRY": "PY",
        "PRT": "PT",
        "MDA": "MD",
        "TKM": "TM",
        "JOR": "JO",
        "NPL": "NP",
        "LSO": "LS",
        "CMR": "CM",
        "GAB": "GA",
        "NER": "NE",
        "BFA": "BF",
        "TGO": "TG",
        "GHA": "GH",
        "GNB": "GW",
        "GIB": "GI",
        "USA": "US",
        "CAN": "CA",
        "MEX": "MX",
        "BLZ": "BZ",
        "PAN": "PA",
        "VEN": "VE",
        "PNG": "PG",
        "EGY": "EG",
        "YEM": "YE",
        "MRT": "MR",
        "GNQ": "GQ",
        "GMB": "GM",
        "HKG": "HK",
        "VAT": "VA",
        "CYN": "CY",
        "CNM": "CY",
        "ATA": "AQ",
        "AUS": "AU",
        "GRL": "GL",
        "FJI": "FJ",
        "NZL": "NZ",
        "NCL": "NC",
        "MDG": "MG",
        "PHL": "PH",
        "LKA": "LK",
        "CUW": "CW",
        "ABW": "AW",
        "BHS": "BS",
        "TCA": "TC",
        "TWN": "TW",
        "JPN": "JP",
        "SPM": "PM",
        "ISL": "IS",
        "PCN": "PN",
        "PYF": "PF",
        "ATF": "TF",
        "SYC": "SC",
        "KIR": "KI",
        "MHL": "MH",
        "TTO": "TT",
        "GRD": "GD",
        "VCT": "VC",
        "BRB": "BB",
        "LCA": "LC",
        "DMA": "DM",
        "UMI": "UM",
        "MSR": "MS",
        "ATG": "AG",
        "KNA": "KN",
        "VIR": "VI",
        "BLM": "BL",
        "PRI": "PR",
        "AIA": "AI",
        "VGB": "VG",
        "JAM": "JM",
        "CYM": "KY",
        "BMU": "BM",
        "HMD": "HM",
        "SHN": "SH",
        "MUS": "MU",
        "COM": "KM",
        "STP": "ST",
        "CPV": "CV",
        "MLT": "MT",
        "JEY": "JE",
        "GGY": "GG",
        "IMN": "IM",
        "ALD": "AX",
        "FRO": "FO",
        "IOA": "IO",
        "IOT": "IO",
        "SGP": "SG",
        "NFK": "NF",
        "COK": "CK",
        "TON": "TO",
        "WLF": "WF",
        "WSM": "WS",
        "SLB": "SB",
        "TUV": "TV",
        "MDV": "MV",
        "NRU": "NR",
        "FSM": "FM",
        "SGS": "GS",
        "FLK": "FK",
        "VUT": "VU",
        "NIU": "NU",
        "ASM": "AS",
        "PLW": "PW",
        "GUM": "GU",
        "MNP": "MP",
        "BHR": "BH",
        "MAC": "MO",
        ]

}
