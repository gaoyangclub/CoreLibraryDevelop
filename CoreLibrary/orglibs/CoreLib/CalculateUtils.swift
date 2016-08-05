//
//  CalculateUtils.swift
//  FinanceApplicationTest
//
//  Created by 高扬 on 15/11/28.
//  Copyright (c) 2015年 高扬. All rights reserved.
//

import UIKit

public class CalculateUtils: AnyObject {
   
    public static func getChartGroupList(positiveValue:Int,negativeValue:Int,segments:Int)->[Int]{
        let normalValue:Float = Float(positiveValue) / Float(negativeValue);
        var rateList:[[Float]] = [];
        for (var rateY:Int = 1; rateY < segments; rateY++)
        {
            let rateX:Int = segments - rateY;
            rateList.append([Float(rateX),Float(rateY)]);
            if(segments % 2 != 0 && rateY == Int(segments / 2)){
                rateList.append([Float(segments) / 2,Float(segments) / 2]);
            }
        }
        var rate0:[Float] = rateList[0];
        var rateM:[Float] = rateList[rateList.count - 1];
        var selectRate:[Float]!;
        if normalValue >= rate0[0] / rate0[1] {//已经大于最大的 就用最大的
            selectRate = rate0;
        }else if normalValue <= rateM[0] / rateM[1] {//小于最小的 就用最小的
            selectRate = rateM;
        }else{
            var preRate:[Float]?;
            for rate in rateList
            {
                if preRate == nil{
                    preRate = rate;
                    continue;
                }
                if normalValue > rate[0] / rate[1] {
                    let dirtPrev:Float = abs(preRate![0] / preRate![1] - normalValue);
                    let dirtNow:Float = abs(normalValue - rate[0] / rate[1]);
                    //说明有接近rate的
                    //selectRate = ???
                    if dirtPrev < dirtNow {//更接近上一个比例
                        selectRate = preRate;
                    }else{
                        selectRate = rate;
                    }
                    break;
                }
                preRate = rate;
            }
        }
        //println(selectRate)
        let selectValue:Float = selectRate[0] / selectRate[1];
        var positiveValue1:Int!
        var negativeValue1:Int!
        if normalValue < selectValue {
            positiveValue1 = Int(ceil(selectRate[0] / selectRate[1] * Float(negativeValue)));
            positiveValue1 = Int(ceil(Float(positiveValue1) / selectRate[0]) * selectRate[0]);
            negativeValue1 = Int(Float(positiveValue1) * selectRate[1] / selectRate[0]);
        }else{
            negativeValue1 = Int(ceil(Float(positiveValue) * selectRate[1] / selectRate[0]));
            negativeValue1 = Int(ceil(Float(negativeValue1) / selectRate[1]) * selectRate[1]);
            positiveValue1 = Int(Float(negativeValue1) * selectRate[0] / selectRate[1]);
        }
//        println("调节后比例    \(positiveValue1):\(negativeValue1)");
        var result:[Int] = [];
        //然后继续均分
        let divisor:Int = (positiveValue1 + negativeValue1) / segments;
        if(selectValue == 1 && segments % 2 == 1){
            result.append(positiveValue1);//比例为1:1 且段数为奇数的需要加半个头尾
        }
        for (var i:Int = positiveValue1 / divisor; i >= 1; i--) 
        {
            result.append(i * divisor);
        }
        result.append(0);
        for (var j:Int = 1; j <= negativeValue1 / divisor; j++) 
        {
            result.append(-j * divisor);
        }
        if(selectValue == 1 && segments % 2 == 1){
            result.append(-negativeValue1);//比例为1:1 且段数为奇数的需要加半个头尾
        }
        return result
    }
    
}
