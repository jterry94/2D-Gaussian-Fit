//
//  ContentView.swift
//  2D Gaussian Fit
//
//  Created by Jeff_Terry on 4/26/23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var myGaussian = Gaussian()
    @State var dataFloat :[[Float]] = []
    @State var xPositions :[Int] = []
    @State var yPositions :[Int] = []
    @State var myOutputText = ""
    
    
    var body: some View {
        VStack {
            
            TextEditor(text: $myOutputText ).padding()
            
            Button("Start", action: fit2DGaussian)
            
            Button("Fit", action: runFit)
        }
        .padding()
    }
    
    func fit2DGaussian(){
        
        xPositions = []
        yPositions = []
        myOutputText = ""
        
        let starCentroid = (x: 75, y: 55)
        let sizeOfStarRegion = 15
        
        let halfStarRegion = sizeOfStarRegion/2
        
        for i in -halfStarRegion...halfStarRegion{
            
            xPositions.append(starCentroid.x + i)
            yPositions.append(starCentroid.y + i)
        }
        
        let dataIntensity :Float = 0.65
        let dataSigmaX :Float = 1.3
        let dataSigmaY :Float = 1.5
        let dataTheta :Float = 0.8
        let datax0 = Float(starCentroid.x)+0.25
        let datay0 = Float(starCentroid.y)+0.75
        let dataOffset :Float = 0.25
        
        dataFloat = myGaussian.calc2DElipticalGaussian(intensity: dataIntensity, sigma_x: dataSigmaX, sigma_y: dataSigmaY, x0: datax0, y0: datay0, theta: dataTheta, offset: dataOffset, xPositions: xPositions, yPositions: yPositions)
        
        for item in dataFloat{
            
            for value in item{
                
                myOutputText += "\(value), "
            }
            myOutputText += "\n"
        }
        
        
        
    }
    
    func runFit(){
        
        self.fit2DGaussian()
        
        let starCentroid = (x: 75, y: 55)
        let sizeOfStarRegion = 15
        
        var guessParameters :[Float] = []
        var hParameters :[Float] = []
        
        
        guessParameters.append(0.50) //Intensity
        guessParameters.append(1.2) //sigma_x
        guessParameters.append(1.4) //sigma_y
        guessParameters.append(Float(starCentroid.x)) //x0
        guessParameters.append(Float(starCentroid.y)) //y0
        guessParameters.append(0.7) //theta
        guessParameters.append(0.10) //offset
        
        print(guessParameters)
        
        for item in guessParameters{
            
            hParameters.append(item * 0.1)
            
        }
        
        hParameters[3] = Float(15.0*0.1)
        hParameters[4] = Float(15.0*0.1)
        
        let numberOfParameters = guessParameters.count
        
        var Jacobian = myGaussian.calculateJacobian(data: dataFloat, size: sizeOfStarRegion, fitParameters: guessParameters, xPositions: xPositions, yPositions: yPositions, hParameters: hParameters, numberOfParameters: numberOfParameters)
        
        let step :Float = 0.1
        
        for i in 0...100{
            
            
            
            for j in 0..<guessParameters.count{
                
                if Jacobian[j] < 0.0{
                    
                    guessParameters[j] += step*hParameters[j]
                }
                else{
                    
                    guessParameters[j]-=step*hParameters[j]
                    
                }
                
               
            }
            print(guessParameters)
            
            let newFitFloat = myGaussian.calc2DElipticalGaussian(intensity: guessParameters[0], sigma_x: guessParameters[1], sigma_y: guessParameters[2], x0: guessParameters[3], y0: guessParameters[4], theta: guessParameters[5], offset: guessParameters[6], xPositions: xPositions, yPositions: yPositions)
            
            let chiSquared = myGaussian.calculateChiSquared(data: dataFloat, fit: newFitFloat, size: sizeOfStarRegion)
            
            print(chiSquared)
            
            hParameters = []
            
            for l in 0 ..< guessParameters.count {

                hParameters.append(guessParameters[l] * 0.1)

            }
            
            hParameters[3] = Float(15.0*0.1)
            hParameters[4] = Float(15.0*0.1)
            
            Jacobian = myGaussian.calculateJacobian(data: dataFloat, size: sizeOfStarRegion, fitParameters: guessParameters, xPositions: xPositions, yPositions: yPositions, hParameters: hParameters, numberOfParameters: numberOfParameters)
            
            print(Jacobian)
        
        }
    

        print(Jacobian)
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
