//
//  Gaussian.swift
//  2D Gaussian Fit
//
//  Created by Jeff_Terry on 4/26/23.
//

import Cocoa

class Gaussian: ObservableObject {
    
    @Published var dataGaussian :[[Float]] = []
    @Published var fitGaussian :[[Float]] = []
    
    /// 2D Eleptical Gaussian Calculator
    /* https://www.hellenicaworld.com/Science/Mathematics/en/GaussianFunction.html#:~:text=In%20fluorescence%20microscopy%20a%202D,are%20used%20for%20Gaussian%20blurs */
    ///
    /// - Parameters:
    ///   - intensity: Intensity
    ///   - sigma_x: sigma in x direction
    ///   - sigma_y: sigma in y direction
    ///   - x0: x centroid
    ///   - y0: y centroid
    ///   - theta: theta rotation angle of elipse
    ///   - offset: static offset
    ///   - xPositions: array describing the xPositions of the cutout from image
    ///   - yPositions: array describing the yPositions of the cutout from image
    /// - Returns: 2D ElipticalGaussian
    func calc2DElipticalGaussian(intensity: Float, sigma_x: Float, sigma_y: Float, x0: Float, y0: Float, theta: Float, offset: Float,  xPositions: [Int], yPositions:[Int])->[[Float]]{
        
        var returnedGaussian :[[Float]] = []
        
        var term1 = (pow(cos(theta),2.0))/(2.0*pow(sigma_x,2.0))
        var term2 = (pow(sin(theta),2.0))/(2.0*pow(sigma_y,2.0))
        
        let a = term1 + term2
        
        term1 = -sin(2.0*theta)/(4.0*pow(sigma_x, 2.0))
        term2 = sin(2.0*theta)/(4.0*pow(sigma_y, 2.0))
        
        let b = term1 + term2
        
        term1 = (pow(sin(theta),2.0))/(2.0*pow(sigma_x,2.0))
        term2 = (pow(cos(theta),2.0))/(2.0*pow(sigma_y,2.0))
        
        let c = term1 + term2
        
        
        
        for j in 0..<yPositions.count{
            
            var rowArray:[Float] = []
            
            for i in 0..<xPositions.count{
                
                
                
                let firstTermExponent = a * pow((Float(xPositions[i])-x0), 2.0)
                let secondTermExponent = 2.0 * b * (Float(xPositions[i])-x0)*((Float(yPositions[j])-y0))
                let thirdTermExponent = c * pow((Float(yPositions[j]) - y0), 2.0)
                
                let elipticalGaussianValue = intensity*exp( -(firstTermExponent + secondTermExponent + thirdTermExponent))
                let offsetGaussianValue = elipticalGaussianValue + offset
                
                rowArray.append(offsetGaussianValue)
            }
            returnedGaussian.append(rowArray)
        }
        
        return(returnedGaussian)
        
        
    }
    
    func calculateChiSquared(data:[[Float]], fit:[[Float]], size: Int) -> Float{
        
        var chisquared :Float = 0.0
        
        for j in 0..<size{
            
            for i in 0..<size{
                
                chisquared += pow((data[i][j] - fit[i][j]), 2.0)
                
            }
        }
        
        return chisquared
        
    }
    
    func calculateJacobian(data:[[Float]], size:Int, fitParameters: [Float],  xPositions: [Int], yPositions:[Int], hParameters: [Float], numberOfParameters: Int) -> [Float]{
        
        var Jacobian :[Float] = []
        var parameterSet1 :[Float] = []
        var parameterSet2 :[Float] = []
        var originalParameter :Float = 0.0
        
        for item in fitParameters{
                
                parameterSet1.append(item)
                parameterSet2.append(item)
                
        }
            
        for i in 0..<numberOfParameters{
            
            originalParameter = parameterSet1[i]
            
            parameterSet1[i] += hParameters[i]
            parameterSet2[i] -= hParameters[i]
            
            let denominator = 2.0*hParameters[i]
            
            let fPlusH = calc2DElipticalGaussian(intensity: parameterSet1[0], sigma_x: parameterSet1[1], sigma_y: parameterSet1[2], x0: parameterSet1[3], y0: parameterSet1[4], theta: parameterSet1[5], offset: parameterSet1[6], xPositions: xPositions, yPositions: yPositions)
            
            let chiOfxPlush = calculateChiSquared(data: data, fit: fPlusH, size: size)
            
            let fMinusH = calc2DElipticalGaussian(intensity: parameterSet2[0], sigma_x: parameterSet2[1], sigma_y: parameterSet2[2], x0: parameterSet2[3], y0: parameterSet2[4], theta: parameterSet2[5], offset: parameterSet2[6], xPositions: xPositions, yPositions: yPositions)
            
            let chiOfxMinush = calculateChiSquared(data: data, fit: fMinusH, size: size)
            
            let JacobianParameter = (chiOfxPlush - chiOfxMinush)/denominator
            
            Jacobian.append(JacobianParameter)
            
            parameterSet1[i] = originalParameter
            parameterSet2[i] = originalParameter
            
        }
        
        
        
        return Jacobian
        
        
        
        
    }
    

}
